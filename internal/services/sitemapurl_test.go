package services_test

import (
	"testing"

	"github.com/stjudewashere/seonaut/internal/config"
	"github.com/stjudewashere/seonaut/internal/models"
	"github.com/stjudewashere/seonaut/internal/services"
)

// sitemapUrlTestRepository tracks whether SaveCrawl is called with the
// sitemap_urls field populated.
type sitemapUrlTestRepository struct {
	saveCrawlCount int
	savedURL       string
	sitemapURLs    string
}

func (r *sitemapUrlTestRepository) SaveCrawl(p models.Project) (*models.Crawl, error) {
	r.saveCrawlCount++
	r.savedURL = p.URL
	r.sitemapURLs = p.SitemapURLs
	return &models.Crawl{Id: 1, ProjectId: p.Id, URL: p.URL}, nil
}

func (r *sitemapUrlTestRepository) GetLastCrawl(p *models.Project) models.Crawl {
	return models.Crawl{}
}

func (r *sitemapUrlTestRepository) GetLastCrawls(p models.Project, limit int) []models.Crawl {
	return []models.Crawl{}
}

func (r *sitemapUrlTestRepository) DeleteCrawlData(c *models.Crawl) {}

func (r *sitemapUrlTestRepository) CountIssuesByPriority(crawlId int64, priority int) int {
	return 0
}

func (r *sitemapUrlTestRepository) UpdateCrawl(c *models.Crawl) {}

type sitemapUrlHandlerRepository struct{}

func (r *sitemapUrlHandlerRepository) SavePageReport(pr *models.PageReport, crawlId int64) (*models.PageReport, error) {
	return pr, nil
}

type sitemapUrlReportManagerRepository struct{}

func (r *sitemapUrlReportManagerRepository) SaveIssues(issues <-chan *models.Issue) {
	for range issues {
	}
}

func newSitemapUrlService(repo *sitemapUrlTestRepository) *services.CrawlerService {
	broker := services.NewPubSubBroker()
	reportManager := services.NewReportManager(&sitemapUrlReportManagerRepository{})
	handler := services.NewCrawlerHandler(&sitemapUrlHandlerRepository{}, broker, reportManager)

	return services.NewCrawlerService(repo, services.CrawlerServicesContainer{
		Broker:         broker,
		ReportManager:  reportManager,
		CrawlerHandler: handler,
		ArchiveService: services.NewArchiveService(""),
		Config:         &config.CrawlerConfig{Agent: "testbot"},
	})
}

// TestStartCrawlerWithSitemapURLs verifies that when a project has
// SitemapURLs set, those URLs are passed to the crawler options and used
// instead of (or in addition to) the robots.txt-discovered sitemaps.
func TestStartCrawlerWithSitemapURLs(t *testing.T) {
	repo := &sitemapUrlTestRepository{}
	svc := newSitemapUrlService(repo)

	p := models.Project{
		Id:          1,
		URL:         "http://localhost:1/",
		SitemapURLs: "https://example.com/sitemap1.xml,https://example.com/sitemap2.xml",
	}

	if err := svc.StartCrawler(p, models.BasicAuth{}); err != nil {
		t.Fatalf("StartCrawler: unexpected error: %v", err)
	}

	if repo.sitemapURLs != "https://example.com/sitemap1.xml,https://example.com/sitemap2.xml" {
		t.Errorf("saved sitemap_urls = %q, want %q", repo.sitemapURLs,
			"https://example.com/sitemap1.xml,https://example.com/sitemap2.xml")
	}
}