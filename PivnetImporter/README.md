# pcf-powertools

Pivnet importer scripts.

'Borrowed' ;) from https://github.com/patrickcrocker/pcf-stuff


pivnet
======
Use 'pivnet' script on OpsMgr or other host with internet acces to download assests from network.pivotal.io
- get api key by clicking on logged in username (top right of screen) and 'edit profile' - API token at bottom of page
- run 'pivnet token <api token>' 

- for any release or stemcell on network.pivotal.io click the (i) icon to the right to get the API download URL.
e.g. https://network.pivotal.io/api/v2/products/elastic-runtime/releases/6293/product_files/26029/download

- run 'pivnet download <release or stemcell url>


opsman
======

User 'opsman' to upload a release to OpsManager engine - can be run on OpsMgr or any other host with network access to it.

- 'opsman login' -providing OpsMgr credentials 

- 'opsman upload <release filename>'

for stemcell uploads

- 'opsman upload-stemcell <stemcell filename>'


Use the OpsManager portal to complete installations.
