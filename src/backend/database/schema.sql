-- Financial Analyst Database Schema - Simplified Version
-- Schema simplifié sans PL/pgSQL pour éviter les warnings

-- Extension pour UUID si nécessaire
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table pour stocker les nouvelles brutes
CREATE TABLE IF NOT EXISTS news_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(1000) NOT NULL,
    url VARCHAR(2048) UNIQUE NOT NULL,
    source VARCHAR(100) NOT NULL,
    content TEXT,
    author VARCHAR(200),
    published_at TIMESTAMP WITH TIME ZONE,
    scraped_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sentiment VARCHAR(20) CHECK (sentiment IN ('bullish', 'bearish', 'neutral')),
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    keywords JSONB DEFAULT '[]',
    market_hours VARCHAR(20) CHECK (market_hours IN ('pre-market', 'market', 'after-hours', 'extended')),
    processing_status VARCHAR(20) DEFAULT 'raw' CHECK (processing_status IN ('raw', 'processed', 'analyzed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table pour stocker les analyses de sentiment
-- Drop and recreate sentiment_analyses to fix constraint issues
DROP TABLE IF EXISTS sentiment_analyses CASCADE;

CREATE TABLE IF NOT EXISTS sentiment_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    analysis_date DATE NOT NULL DEFAULT CURRENT_DATE,
    analysis_time TIME NOT NULL DEFAULT CURRENT_TIME,
    overall_sentiment VARCHAR(20) CHECK (overall_sentiment IN ('bullish', 'bearish', 'neutral')),
    score INTEGER CHECK (score >= -100 AND score <= 100),
    risk_level VARCHAR(20) CHECK (risk_level IN ('low', 'medium', 'high')),
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    catalysts JSONB DEFAULT '[]',
    summary TEXT,
    news_count INTEGER DEFAULT 0,
    sources_analyzed JSONB DEFAULT '{}',
    -- Nouveaux champs pour algorithmes avancés
    market_session VARCHAR(20) CHECK (market_session IN ('pre-market', 'regular', 'after-hours', 'weekend')),
    inference_duration_ms INTEGER, -- Temps d'inférence en millisecondes
    kilocode_tokens_used INTEGER DEFAULT 0,
    kilocode_model_version VARCHAR(50),
    volatility_estimate DECIMAL(5,2), -- Estimation de volatilité 0-100
    market_regime VARCHAR(20) CHECK (market_regime IN ('bull', 'bear', 'sideways', 'transitional')),
    sentiment_strength VARCHAR(15) CHECK (sentiment_strength IN ('weak', 'moderate', 'strong', 'extreme')),
    key_insights JSONB DEFAULT '[]', -- Insights spécifiques pour algorithmes
    trading_signals JSONB DEFAULT '{}', -- Signaux de trading générés
    technical_bias VARCHAR(20) CHECK (technical_bias IN ('oversold', 'neutral', 'overbought')),
    news_impact_level VARCHAR(15) CHECK (news_impact_level IN ('low', 'medium', 'high', 'critical')),
    algorithm_confidence DECIMAL(3,2), -- Confiance de l'algorithme 0-1
    metadata JSONB DEFAULT '{}', -- Métadonnées additionnelles
    validation_flags JSONB DEFAULT '{}', -- Flags de validation pour algorithmes
    performance_metrics JSONB DEFAULT '{}', -- Métriques de performance
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table pour tracking les sources et leur disponibilité
CREATE TABLE IF NOT EXISTS news_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    base_url VARCHAR(500),
    rss_url VARCHAR(500),
    last_scraped_at TIMESTAMP WITH TIME ZONE,
    last_success_at TIMESTAMP WITH TIME ZONE,
    success_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    scrape_interval_minutes INTEGER DEFAULT 60,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table pour les sessions de scraping
CREATE TABLE IF NOT EXISTS scraping_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed')),
    news_scraped INTEGER DEFAULT 0,
    errors JSONB DEFAULT '[]',
    sources_used JSONB DEFAULT '[]',
    duration_seconds INTEGER
);

-- Index pour optimiser les performances
CREATE INDEX IF NOT EXISTS idx_news_items_published_at ON news_items(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_items_source ON news_items(source);
CREATE INDEX IF NOT EXISTS idx_news_items_sentiment ON news_items(sentiment);
CREATE INDEX IF NOT EXISTS idx_news_items_market_hours ON news_items(market_hours);
CREATE INDEX IF NOT EXISTS idx_news_items_keywords ON news_items USING GIN(keywords);
CREATE INDEX IF NOT EXISTS idx_news_items_processing_status ON news_items(processing_status);
CREATE INDEX IF NOT EXISTS idx_news_items_scraped_at ON news_items(scraped_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_items_created_at ON news_items(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sentiment_analyses_analysis_date ON sentiment_analyses(analysis_date DESC);
CREATE INDEX IF NOT EXISTS idx_sentiment_analyses_overall_sentiment ON sentiment_analyses(overall_sentiment);

CREATE INDEX IF NOT EXISTS idx_news_sources_last_scraped ON news_sources(last_scraped_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_sources_is_active ON news_sources(is_active);

CREATE INDEX IF NOT EXISTS idx_scraping_sessions_started_at ON scraping_sessions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_scraping_sessions_status ON scraping_sessions(status);

-- Insertion des sources par défaut
INSERT INTO news_sources (name, rss_url, scrape_interval_minutes) VALUES
('ZeroHedge', 'http://feeds.feedburner.com/zerohedge/feed', 60),
('CNBC', 'https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=10000664', 60),
('FinancialJuice', NULL, 120)
ON CONFLICT (name) DO NOTHING;

-- Vues simplifiées pour les requêtes communes (sans PL/pgSQL)
CREATE OR REPLACE VIEW latest_news AS
SELECT
    id,
    title,
    source,
    url,
    published_at,
    scraped_at,
    sentiment,
    confidence,
    keywords,
    market_hours
FROM news_items
WHERE published_at >= NOW() - INTERVAL '7 days'
ORDER BY published_at DESC;

CREATE OR REPLACE VIEW daily_news_summary AS
SELECT
    DATE(published_at) as analysis_date,
    source,
    COUNT(*) as news_count,
    COUNT(CASE WHEN sentiment = 'bullish' THEN 1 END) as bullish_count,
    COUNT(CASE WHEN sentiment = 'bearish' THEN 1 END) as bearish_count,
    COUNT(CASE WHEN sentiment = 'neutral' THEN 1 END) as neutral_count,
    COUNT(CASE WHEN market_hours = 'market' THEN 1 END) as market_hours_count
FROM news_items
WHERE published_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(published_at), source
ORDER BY analysis_date DESC, source;

CREATE OR REPLACE VIEW source_performance AS
SELECT
    ns.name,
    ns.last_scraped_at,
    ns.last_success_at,
    ns.success_count,
    ns.error_count,
    CASE
        WHEN ns.success_count + ns.error_count = 0 THEN 0
        ELSE ROUND((ns.success_count::DECIMAL / (ns.success_count + ns.error_count)) * 100, 2)
    END as success_rate,
    CASE
        WHEN ns.last_success_at >= NOW() - INTERVAL '1 hour' THEN 'excellent'
        WHEN ns.last_success_at >= NOW() - INTERVAL '6 hours' THEN 'good'
        WHEN ns.last_success_at >= NOW() - INTERVAL '24 hours' THEN 'warning'
        ELSE 'critical'
    END as health_status
FROM news_sources ns
ORDER BY success_rate DESC;

-- Table pour les séries temporelles de marché (pour algorithmes)
CREATE TABLE IF NOT EXISTS market_time_series (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    sentiment_score INTEGER CHECK (sentiment_score >= -100 AND sentiment_score <= 100),
    volatility_estimate DECIMAL(5,2),
    news_impact_score DECIMAL(5,2),
    market_session VARCHAR(20) CHECK (market_session IN ('pre-market', 'regular', 'after-hours', 'weekend')),
    trading_volume_trend VARCHAR(10) CHECK (trading_volume_trend IN ('low', 'normal', 'high', 'extreme')),
    key_events JSONB DEFAULT '[]',
    technical_indicators JSONB DEFAULT '{}',
    correlation_metrics JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table pour les patterns de marché détectés
CREATE TABLE IF NOT EXISTS market_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pattern_name VARCHAR(100) NOT NULL,
    pattern_type VARCHAR(50) CHECK (pattern_type IN ('sentiment', 'volatility', 'correlation', 'momentum', 'reversal')),
    detection_date TIMESTAMP WITH TIME ZONE NOT NULL,
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    duration_minutes INTEGER,
    strength VARCHAR(15) CHECK (strength IN ('weak', 'moderate', 'strong', 'extreme')),
    description TEXT,
    implications JSONB DEFAULT '{}',
    historical_accuracy DECIMAL(3,2),
    related_analyses UUID[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ... (algorithm_performance table skipped for brevity if not changing) ...

-- Vue pour les patterns actifs
CREATE OR REPLACE VIEW active_market_patterns AS
SELECT
    id,
    pattern_name,
    pattern_type,
    detection_date,
    confidence_score,
    strength,
    description,
    historical_accuracy,
    EXTRACT(DAY FROM NOW() - detection_date) as age_days
FROM market_patterns
WHERE is_active = TRUE
  AND detection_date >= NOW() - INTERVAL '7 days'
ORDER BY confidence_score DESC, detection_date DESC;

-- Vue pour les séries temporelles récentes
CREATE OR REPLACE VIEW recent_time_series AS
SELECT
    timestamp,
    sentiment_score,
    volatility_estimate,
    news_impact_score,
    market_session,
    trading_volume_trend,
    EXTRACT(EPOCH FROM timestamp) as epoch_timestamp
FROM market_time_series
WHERE timestamp >= NOW() - INTERVAL '24 hours'
ORDER BY timestamp DESC;