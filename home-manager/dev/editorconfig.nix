{
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_style = "space";
        indent_size = 2;
        trim_trailing_whitespace = true;
        insert_final_newline = true;
      };

      # Two trailing spaces are a hard line break in Markdown.
      "*.md" = {
        trim_trailing_whitespace = false;
      };

      "{Makefile,*.mk,*.go}" = {
        indent_style = "tab";
      };

      "*.py" = {
        indent_size = 4;
      };
    };
  };
}
