# npm ERR! code ELIFECYCLE解决方案

``` node
#报错描述
npm ERR! code ELIFECYCLE
npm ERR! errno 1
npm ERR! node-sass@4.14.1 postinstall: `node scripts/build.js`
npm ERR! Exit status 1
npm ERR! 
npm ERR! Failed at the node-sass@4.14.1 postinstall script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

```

解决方案：

```node
npm cache clean --force
rm -rf node_modules
rm -rf package-lock.json
npm install
```
