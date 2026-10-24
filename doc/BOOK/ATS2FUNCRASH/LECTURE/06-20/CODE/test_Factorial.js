// A test of Factorial_dats.js under Node.js: a tiny stub of the DOM
// stands for the browser (see Factorial.html for the real page).
// usage: node test_Factorial.js (PATSHOME is set)
var fs = require('fs');
var vm = require('vm');
var LIB = process.env.PATSHOME + '/contrib/libatscc2js';
var elems = {
  funarg1: { value: '10' },
  theOutput: { innerHTML: '' }
};
global.document = { getElementById: function(id) { return elems[id]; } };
[ '/CATS/basics_cats.js'
, '/CATS/bool_cats.js'
, '/CATS/integer_cats.js'
, '/CATS/string_cats.js'
, '/CATS/PRINT/print_store_cats.js'
].forEach(function(f) {
  vm.runInThisContext(fs.readFileSync(LIB + f).toString(), { filename: f });
});
vm.runInThisContext(fs.readFileSync('Factorial_dats.js').toString(), { filename: 'Factorial_dats.js' });
Factorial__dynload();
Factorial__evaluate();
console.log(elems.theOutput.innerHTML);
if (elems.theOutput.innerHTML.indexOf('is 3628800') < 0) process.exit(1);
