var fs=require('fs'),vm=require('vm');var L=process.env.PATSHOME+'/contrib/libatscc2js';
var elems={out:{innerHTML:''}};
global.document={getElementById:function(i){return elems[i]||null},createElement:function(t){return {tag:t,innerHTML:''}}};
['/CATS/basics_cats.js','/CATS/bool_cats.js','/CATS/integer_cats.js','/CATS/string_cats.js','/HTML/DOM/CATS/document_cats.js'].forEach(function(f){vm.runInThisContext(fs.readFileSync(L+f).toString(),{filename:f})});
vm.runInThisContext(fs.readFileSync('document_dats.js').toString());vm.runInThisContext(fs.readFileSync('test02_dats.js').toString());
test02__dynload(); run(); console.log(elems.out.innerHTML);
if (elems.out.innerHTML !== 'hello') process.exit(1);
