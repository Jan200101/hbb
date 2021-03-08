# hbb
an attempt at getting hbb to work with modern devkitPPC

based on the OpenShopChannel [archive](https://github.com/OpenShopChannel/HomebrewBrowser)
from the [source code](https://www.codemii.com/2020/01/02/homebrew-browser-source/#comments) released by teknecal

## Notes
- the codemii.com domain has been replaced with oscwii.org provided by the [OpenShopChannel team](https://github.com/OpenShopChannel/) (the domain can be configured in the Makefile)
- Update checks have been removed 

## TODO
- [x] replace GRRLIB with the upstream
- [ ] replace unzip with upstream ([tracker](https://github.com/devkitPro/pacman-packages/issues/215))
- [ ] correct image placement
- [ ] migrate mp3player from libogc/libmad to this project and use upstream libmad