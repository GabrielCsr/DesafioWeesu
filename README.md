# Desafio Weesu - Aplicação Delphi com Mercado Livre API

## Como Iniciar a Aplicação

### 1. **Executar o Docker Compose**
  Para iniciar todos os serviços utilizados pelo sistema acesse o diretório `/docker/` e digite o seguinte comando:
  ```bash
  docker-compose up -d
  ```
  Aguarde até completar totalmente a inicialização dos conteiners antes de ir para os próximos passos. 

### 2. **Executar o Micro Serviço(Responsável pela persistencia dos dados alterados na aplicação principal)**
  Acesse o diretório `/MS_MercadoLivre/bin/` e execute o arquivo `MS_MercadoLivre.exe`. Ao executar será configurado todos os dados do RabbitMQ e iniciará o consumo da fila de produtos.

### 3. **Executar a Aplicação Principal**
  Acesse o diretório `/App/bin/` e execute o arquivo `Desafio.exe`.

## Como Utilizar a Aplicação

### 1. **Configurações iniciais**
 - Ao iniciar a aplicação pressione o botão "Configurações" presente na parte inferior da barra lateral.
 - Ao acessar a rotina de configurações você verá no canto inferior direito um informativo `Passo a Passo para gerar as informações: `. Clique na interrogação`?` ao lado do descritivo e você será redirecionado a pagina do mercado livre que contem as informações de como gerar os dados de autorização para utilização da API. 
 - Após realizar todo o processo e gerar os dados necessários, inclua-os nos campos presentes na rotina de configuração.
 - O code pode ser gerado pela própria rotina. Acionando o botão "Gerar Code" você será redirecionado a pagina de autorização do Mercado Livre.
 - Após realizar a autorização você será redirecionado ao URI redirect definido nas configurações do Mercado Livre, e nela conterá o `code`.
 - Copie o `code` da URL e cole no campo `Code` do sistema.
 - Após preencher todas as configurações, incluindo o Code, pressione o botão "Salvar".
   
### 2. **Buscar Produtos**

- Pressione o botão `Mercado Livre` presente na barra lateral.
- Digite uma palavra-chave relacionada aos produtos que deseja buscar, como **"Samsung s9"** ou **"Relógio"**.
- Clique no botão **"Buscar"** para realizar a pesquisa.

A aplicação fará uma requisição à API do Mercado Livre e listará os produtos encontrados em um grid, incluindo informações como nome, descrição, preço e imagem do produto.

### 3. **Editar Produto**

- Para editar um produto encontrado, clique na celula que deseja alterar, como **nome** ou **preço** e digite o valor desejado.

### 4. **Persistência Assíncrona**

Quando você salva as alterações de um produto, as mudanças são enviadas para uma fila **RabbitMQ** para serem processadas de forma assíncrona por um microserviço. O microserviço processa a mensagem e persiste os dados no banco de dados de forma eficiente, sem bloquear a aplicação principal.

### 5. **Visualização de Alterações no Banco de Dados**

Após salvar as alterações, a aplicação continuará funcionando normalmente. Para verificar se as alterações foram persistidas no banco de dados, você pode acessar a base de dados diretamente (por meio de uma interface de gerenciamento de banco de dados ou via SQL) e conferir as atualizações.

### **Observações**
  - Dados referentes a configurações serão persistidos na tabela **configuracoes** do banco de dados.
  - Dados referentes a chaves de autenticação, como `access-token` e `refresh-token` serão persistidos na tabela **tokens**.
  - Dados referentes a produtos serão persistidos na tabela **produtos**.
---
## EndPoints Para Controle do Micro Serviço

 ##  1. **EndPoint para controle do estado do micro serviço** 
   ```bash
   Get http://localhost:3333/service/status
   ```
  Possiveis resultados:
   ```bash
   {"status": "rodando", "mensagem": "Consumindo fila de produtos"}
   ```
   ```bash
   {"status": "rodando", "mensagem": "Não consumindo fila de produtos"}
   ```
##  2. **EndPoint iniciar ou pausar o consumo da fila de produtos** 
  `Post`   - Inicia o consumo da fila.
  `Delete` - Pausa o consumo da fila.
  ```bash
  http://localhost:3333/produtos/fila/consumir
  ```
 Possiveis resultados:
  ```bash
  Consumo da fila de produtos iniciado com sucesso!
  ```
  ```bash
  Consumo da fila interrompido com sucesso!
  ```
   

## Considerações Técnicas
  - O projeto foi desenvolvido inteiramente em Delphi 12.
  - O microserviço utiliza o Horse como framework.
  - Banco de dados: MySQL 5.7.
  - Message Broker: RabbitMQ, com AMQP para configuração e STOMP para consumo de filas.
  - Docker foi utilizado para facilitar a configuração do banco de dados e do Message Broker.
