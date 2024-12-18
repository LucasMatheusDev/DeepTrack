# DeepTrack

DeepTrack is a software tool designed to analyze projects based on interactions between files and layers, providing valuable insights into dependencies and organization. It helps developers and teams understand how project components are interconnected, identifying cross-references and import flows.

## Features

### CLI (Command Line Interface)
DeepTrack offers a powerful command-line interface that allows you to:

- Analyze the project by specifying the code path.
- Return data on interactions between files and layers in JSON format, including information about:
  - Which files depend on others.
  - Where files are referenced.
  - Which layers depend on others.

This approach is ideal for integration with scripts and automation processes.

#### Available Commands

- **`files`**: Returns a detailed analysis of files, including import and export dependencies.
  ```bash
  deeptrack-cli files --path /path/to/your/project
  ```

- **`layers`**: Analyzes the project layers, returning interactions between them.
  ```bash
  deeptrack-cli layers --path /path/to/your/project
  ```

- **`files-and-layers`**: Performs a combined analysis of files and layers, returning both results in JSON format.
  ```bash
  deeptrack-cli files-and-layers --path /path/to/your/project
  ```

- **Common Options:**
  - `--import-regex`: Defines the pattern for importing dependencies.
  - `--export-regex`: Defines the pattern for exporting dependencies.
  - `--file-regex`: Defines the pattern for file names to be analyzed.
  - `--layer-regex`: Defines the pattern for layer validation.

### GUI (Graphical User Interface)
DeepTrack also includes an intuitive graphical interface that offers:

- **Mind Map:** Visualizes interactions between files in a mind map format, highlighting their connections.
- **Deletion Suggestions:** Identifies unreferenced files and suggests their removal.
- **Import Flow:** A visual representation inspired by Clean Architecture, using circles to show which layers know about others. This helps ensure that project dependencies adhere to architectural rules.

Both the mind map and the import flow visualization allow you to capture screenshots for future documentation.

## Objective

The main goal of DeepTrack is to provide a clear and detailed understanding of a project's structure by analyzing its layers and imports. This helps to:

- Detect unwanted dependencies.
- Better organize project components.
- Identify obsolete or unused files.
- Ensure the project adheres to architectural best practices.

## How to Use

### Using the CLI
1. Install DeepTrack following the provided instructions.
2. Run the appropriate command based on the desired analysis type. For example:

   ```bash
   deeptrack-cli files-and-layers --path /path/to/your/project --import-regex "^package:" --file-regex "\.dart$"
   ```

3. The result will be returned in JSON format, showing interactions between files and layers.

### Using the GUI
1. Open the DeepTrack graphical interface.
2. Select the project path to start the analysis.
3. Explore the following features:
   - Mind map visualization.
   - Suggestions for files to delete.
   - Import flow based on Clean Architecture.
4. Use the screenshot tool to save visualizations as documentation.

## Contribution
Contributions to DeepTrack are welcome! If you find bugs, have suggestions, or want to collaborate on new features, feel free to open issues or submit pull requests in the official repository.

## License
This project is licensed under the [MIT License](LICENSE).

