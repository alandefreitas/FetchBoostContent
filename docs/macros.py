import os

def declare_variables(variables, macro):
    @macro
    def code_snippet(filename: str, snippet: str = "", language: str = ""):
        """
        Load code from a file and save as a preformatted code block.
        If a language is specified, it's passed in as a hint for syntax highlighters.

        Example usage in markdown:

            {{code_from_file("code/myfile.py", "python")}}

        """
        docs_dir = variables.get("docs_dir", "docs")

        # Look for file
        abs_root_path = os.path.abspath(os.path.join(docs_dir, "..", filename))
        abs_docs_path = os.path.abspath(os.path.join(docs_dir, filename))
        abs_examples_path = os.path.abspath(os.path.join(docs_dir, "../examples/", filename))
        abs_path = ''
        if os.path.exists(abs_root_path):
            abs_path = abs_root_path
        elif os.path.exists(abs_docs_path):
            abs_path = abs_docs_path
        elif os.path.exists(abs_examples_path):
            abs_path = abs_examples_path

        if language == '':
            extension = os.path.splitext(abs_path)[1]
            if extension == '.txt':
                if abs_path.endswith('CMakeLists.txt'):
                    language = 'cmake'
                else:
                    language = 'text'
            elif extension == '.cmake':
                language = 'cmake'
            elif extension == '.md':
                language = 'markdown'
            else:
                language = 'cpp'
            print(f"File: {abs_path}\nextension: {extension}\nlanguage: {language}")

        # File not found
        if not os.path.exists(abs_path):
            return f"""<b>File not found: {filename}</b>"""

        # Read snippet from file
        with open(abs_path, "r") as f:
            if not snippet:
                return (
                    f"""```{language}\n{f.read()}\n```"""
                )
            else:
                # Snippet tags
                comment_token = '//'
                if language == 'markdown':
                    comment_token = '<!--'
                elif language != 'cpp':
                    comment_token = '#'
                snippet_open = comment_token + '['
                snippet_close = comment_token + ']'

                # Extract the snippet
                contents = f.read()
                open_token = snippet_open + snippet
                start_pos = contents.find(open_token)
                if start_pos == -1:
                    return f"""<b>Snippet {open_token} not found in {filename}</b>"""
                start_pos += len(open_token)

                close_token = snippet_close + snippet
                end_pos = contents.find(close_token, start_pos)
                if end_pos == -1:
                    end_pos = contents.find(snippet_close, start_pos)
                if end_pos == -1:
                    return f"""<b>Snippet {snippet} not found in {filename}</b>"""
                contents = contents[start_pos:end_pos]

                # Identify snippet header
                content_lines = contents.splitlines()
                first_line = content_lines[0]
                header = ''
                if not first_line.isspace() and not len(first_line) == 0:
                    header = first_line.strip()

                # Identify indent
                indent_size = 20
                for line in content_lines[1:]:
                    if not line.isspace() and not len(line) == 0:
                        first_char_pos = len(line) - len(line.lstrip())
                        indent_size = min(indent_size, first_char_pos)

                # Open code block
                contents = ''
                is_code = language not in ['markdown', 'text']
                if is_code:
                    if len(header) != 0:
                        contents += '=== "' + header + '"\n\n    '
                    contents += '```' + language
                    if len(content_lines) > 10:
                        contents += ' linenums="1" '
                    contents += '\n'

                # Fill block with appropriate indentation
                for line in content_lines[1:]:
                    if line.lstrip().startswith(snippet_open):
                        continue
                    if line.lstrip().startswith(snippet_close):
                        continue
                    if is_code and len(header) != 0:
                        contents += '    '
                    contents += line[indent_size:] + '\n'

                # Close code block
                if is_code:
                    if len(header) != 0:
                        contents += '    '
                    contents += '```\n'

                return contents

    @macro
    def all_code_snippets(filename: str, language: str = "cpp"):
        """
        Load code from a file and save as a preformatted code block.
        If a language is specified, it's passed in as a hint for syntax highlighters.

        Example usage in markdown:

            {{all_code_snippets("code/myfile.py", "python")}}

        """
        docs_dir = variables.get("docs_dir", "docs")

        # Look for file
        abs_docs_path = os.path.abspath(os.path.join(docs_dir, filename))
        abs_root_path = os.path.abspath(os.path.join(docs_dir, "..", filename))
        abs_examples_path = os.path.abspath(os.path.join(docs_dir, "../examples/", filename))
        abs_path = ''
        if os.path.exists(abs_docs_path):
            abs_path = abs_docs_path
        elif os.path.exists(abs_root_path):
            abs_path = abs_root_path
        elif os.path.exists(abs_examples_path):
            abs_path = abs_examples_path

        # File not found
        if not os.path.exists(abs_path):
            return f"""<b>File not found: {filename}</b>"""

        # Read all snippets from file
        with open(abs_path, "r") as f:
            # Snippet tags
            snippet_open = '//[' if language == 'cpp' else '#['
            snippet_close = '//]' if language == 'cpp' else '#]'

            # Extract the snippet names
            contents = f.read()
            snippets = []
            start_pos = contents.find(snippet_open)
            while start_pos != -1:
                name_start = start_pos + len(snippet_open)
                name_end = contents.find(' ', name_start)
                if name_end != -1:
                    snippets.append(contents[name_start:name_end])
                start_pos = contents.find(snippet_open, name_end)

            # Render all snippets
            contents = ''
            for snippet in snippets:
                contents += code_snippet(filename, snippet, language)
                contents += '<hr>'

            contents += '<a href="https://github.com/alandefreitas/moderncpp/edit/master/'
            contents += filename
            contents += '" '
            contents += 'title="{{ config.site_name }}" class="md-button" target="_blank">\n'
            contents += ':octicons-code-square-16: Share Snippets\n'
            contents += '</a>\n'

            return contents