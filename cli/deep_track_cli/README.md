# DeepTrack CLI

[Instale o CLI](cli/deep_track_cli/bin/deep_track_cli.exe). 

### CLI (Command Line Interface)
DeepTrack oferece uma interface de linha de comando poderosa que permite:

- Analisar o projeto especificando o caminho do código.
- Retornar os dados de interações entre arquivos e camadas em formato JSON, com informações sobre:
  - Quais arquivos dependem de outros.
  - Onde os arquivos são referenciados.
  - Quais camadas dependem de outras.

Essa abordagem é ideal para integração com scripts e processos de automação.

#### Comandos Disponíveis

- **`files`**: Retorna a análise detalhada de arquivos, incluindo dependências de importação e exportação.
  ```bash
  deeptrack-cli files --path /caminho/para/seu/projeto
  ```

- **`layers`**: Analisa as camadas do projeto, retornando as interações entre elas.
  ```bash
  deeptrack-cli layers --path /caminho/para/seu/projeto
  ```

- **`files-and-layers`**: Realiza uma análise combinada de arquivos e camadas, retornando ambos os resultados em formato JSON.
  ```bash
  deeptrack-cli files-and-layers --path /caminho/para/seu/projeto
  ```

- **Opções Comuns:**
  - `--import-regex`: Define o padrão para importar dependências.
  - `--export-regex`: Define o padrão para exportar dependências.
  - `--file-regex`: Define o padrão de nomes de arquivos a serem analisados.
  - `--layer-regex`: Define o padrão para validação de camadas.

