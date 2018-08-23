setupClient:
	cd client && stack setup

buildClient:
	cd client && stack build
	cd client && cp -Rf ../static/* $$(stack path --local-install-root)/bin/InnerEarClient.jsexe/

staticClient:
	cd client && cp -Rf ../static/* $$(stack path --local-install-root)/bin/InnerEarClient.jsexe/	

buildClientForceDirty:
	cd client && stack build --force-dirty
	cd client && cp -Rf ../static/* $$(stack path --local-install-root)/bin/InnerEarClient.jsexe/

cleanClient:
	cd client && stack clean

bootTemporaryWebServer:
	cd client && cd $$(stack path --local-install-root)/bin/InnerEarClient.jsexe/; npm install
	cd client && node $$(stack path --local-install-root)/bin/InnerEarClient.jsexe/temporaryWebServer.js;

openClient:
	cd client && open $$(stack path --local-install-root)/bin/InnerEarClient.jsexe/index.html

setupServer:
	cd server && stack setup

buildServer:
	cd server && stack build --ghc-options='-threaded'

cleanServer:
	cd server && stack clean

bootServer:
	cd release && ./InnerEarServer

release:
	-rm -rf release
	mkdir release
	cd client && cp -Rf $$(stack path --local-install-root)/bin/InnerEarClient.jsexe ../release/
	cd server && cp -Rf $$(stack path --local-install-root)/bin/InnerEarServer ../release/InnerEarServer

updateClientWithRunningServer: buildClient
	cd client && cp -Rf $$(stack path --local-install-root)/bin/InnerEarClient.jsexe ../release/

buildReleaseTest: buildClient buildServer release bootServer

ghciServer:
	cd server && stack ghci


# development builds

PRODUCTION_WORK_DIR=.stack-work-production/

prodBuildClient:
	cd client && stack --work-dir $(PRODUCTION_WORK_DIR) build --ghc-options="-DGHCJS_BROWSER -O2"

releaseProdClient:
	cd client && cp -Rf $$(stack --work-dir $(PRODUCTION_WORK_DIR) path --local-install-root)/bin/InnerEarClient.jsexe ../release/	

# profile builds

profBuildClient:
	cd client && stack build --profile
