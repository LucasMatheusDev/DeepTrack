# DeepTrack

DeepTrack é um software desenvolvido para analisar projetos com base nas interações entre arquivos e camadas, oferecendo insights valiosos sobre dependências e organização. Ele ajuda desenvolvedores e equipes a entenderem como os componentes de um projeto estão interligados, identificando referências cruzadas e fluxos de importação.

## Funcionalidades

### CLI (Command Line Interface)
DeepTrack oferece uma interface de linha de comando poderosa que permite:

- Analisar o projeto especificando o caminho do código.
- Retornar os dados de interações entre arquivos e camadas em formato JSON, com informações sobre:
  - Quais arquivos dependem de outros.
  - Onde os arquivos são referenciados.
  - Quais camadas dependem de outras.

Essa abordagem é ideal para integração com scripts e processos de automação, um bom exemplo de uso é a validação da implementação de arquiteturas em tempo de PR.

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

### GUI (Graphical User Interface)
DeepTrack também conta com uma interface gráfica intuitiva, que oferece:

- **Mapa Mental:** Visualização das interações entre arquivos em formato de mapa mental, destacando as conexões entre eles.
   ![Mapa Mental](assets/mind.png)
- **Sugestão de Exclusão:** Identifica arquivos sem referências e sugere que sejam excluídos.
   ![Fluxo de Importação](assets/deleted.png)
- **Fluxo de Importação:** Uma representação visual inspirada em Clean Architecture, utilizando círculos para mostrar quais camadas conhecem as outras. Isso ajuda a verificar se as dependências do projeto estão respeitando as regras arquiteturais.
    ![Fluxo de Importação](assets/clean-arch.png)

Tanto o mapa mental quanto a visualização do fluxo de importação permitem capturar screenshots para documentação futura.


## Objetivo

O principal objetivo do DeepTrack é oferecer uma compreensão clara e detalhada sobre a estrutura de um projeto, analisando suas camadas e importações. Com isso, ele ajuda a:

- Detectar dependências não desejadas.
- Organizar melhor os componentes do projeto.
- Identificar arquivos obsoletos ou sem uso.
- Garantir que o projeto respeite boas práticas arquiteturais.

## Como Usar
 <!-- Link para read do cli -->
  
### Usando o CLI
  [Documentação](cli/deep_track_cli/README.md) do DeepTrack CLI.

   <a href="https://github.com/LucasMatheusDev/DeepTrack/raw/refs/heads/main/cli/deep_track_cli/bin/deep_track_cli.exe"
  download="deep_track_cli.exe">Instale o CLI 

### Usando o GUI
  [Documentação](gui/deep_track_gui/README.md) do DeepTrack GUI.

## Contribuição
Contribuições para o DeepTrack são bem-vindas! Se você encontrar bugs, tiver sugestões ou desejar colaborar com novas funcionalidades, fique à vontade para abrir issues ou enviar pull requests no repositório oficial.


