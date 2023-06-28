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

npm i axios
```

# gyp ERR! stack Error: EACCES: permission denied, mkdir问题解决方案

解决方案：`sudo npm i --unsafe-perm`
原因
还是权限问题

就是说 npm 出于安全考虑不支持以 root 用户运行，即使你用 root 用户身份运行了，npm 会自动转成一个叫 nobody 的用户来运行，而这个用户几乎没有任何权限。这样的话如果你脚本里有一些需要权限的操作，比如写文件（尤其是写 /root/.node-gyp），就会崩掉了。

为了避免这种情况，要么按照 npm 的规矩来，专门建一个用于运行 npm 的高权限用户；要么加 --unsafe-perm 参数，这样就不会切换到 nobody 上，运行时是哪个用户就是哪个用户，即是 root。
