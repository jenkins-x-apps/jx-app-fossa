if [ ! -f go.mod ]; then
  # Fossa requires a mod file or lock file
  go mod init
fi
curl https://raw.githubusercontent.com/fossas/fossa-cli/master/install.sh | bash 
fossa init
export FOSSA_API_KEY=e8f6249ad76777febbcc6f59b43074b0
fossa analyze
fossa test
