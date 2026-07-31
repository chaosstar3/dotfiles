# Dependencies
When installing external libraries or dependencies, always create a separate git commit
for the installation before continuing with the current work.
Before running the git command, briefly inform the user that this commit is for a dependency installation.
- Commit title: `dep: ` prefix followed by the package name(s); append a brief reason if it fits (e.g., `dep: requests — http client`)
- Commit body: the exact command(s) used to install; add any details about why this dependency was chosen

# Python
Always use a virtual environment when running Python scripts:
- Create with: `python -m venv .venv`
- Activate with: `source .venv/bin/activate`

