#
# Environment variables that are safe to commit.
#
# Anything secret belongs in ~/.zshenv.local instead — see zshenv.local.example.
# Currently kept there: KAGGLE_KEY, GITHUB_TOKEN, HF_TOKEN.
#

# Build Docker images with BuildKit, including via docker-compose.
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Kaggle account name. The matching KAGGLE_KEY is a secret and lives in
# ~/.zshenv.local; both must be set for the kaggle CLI to authenticate.
export KAGGLE_USERNAME='nikitakolesnikov'

# A literal placeholder, not a credential: a local Ollama server requires the
# variable to be set but ignores its value.
export OLLAMA_API_KEY=ollama
