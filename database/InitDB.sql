CREATE TABLE IF NOT EXISTS configuracoes (
    id_configuracao INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(10) NOT NULL UNIQUE,  
    valor TEXT NOT NULL, 
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    atualizado_em DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE INDEX idx_nome ON configuracoes (nome);

CREATE TABLE IF NOT EXISTS tokens (
	id_token INT AUTO_INCREMENT PRIMARY KEY,
	id_usuario BIGINT NOT NULL UNIQUE,
	access_token VARCHAR(512) NOT NULL,
	refresh_token VARCHAR(512) NOT NULL,
	expira_em INT NOT NULL,
	criado_em DATETIME NOT NULL,
	atualizado_em DATETIME NOT NULL 
); 
CREATE INDEX idx_id_usuario ON tokens (id_usuario);

CREATE TABLE IF NOT EXISTS produtos (
	sku VARCHAR(100) PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	preco DECIMAL(15,2) NOT NULL,
	url_imagem TEXT
);
CREATE INDEX idx_sku ON produtos (sku);