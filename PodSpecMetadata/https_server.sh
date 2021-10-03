cd ~/
mkdir .localhost-ssl

sudo openssl genrsa -out ~/.localhost-ssl/localhost.key 2048
sudo openssl req -new -x509 -key ~/.localhost-ssl/localhost.key -out ~/.localhost-ssl/localhost.crt -days 3650 -subj /CN=localhost
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/.localhost-ssl/localhost.crt

npm install -g http-server
echo " 
function https-server() {
  http-server --ssl --cert ~/.localhost-ssl/localhost.crt --key ~/.localhost-ssl/localhost.key
}
" >> ~/.bash_profile
source ~/.bash_profile

echo "You're ready to use https on localhost 💅"
echo "Navigate to a project directory and run:"
echo ""
echo "https-server"
