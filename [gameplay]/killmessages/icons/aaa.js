const fs = require('fs')

const path = 'icons'

fs.readdir('./' + path, 'ascii', (_, files) => {
    for (let name of files.filter(a => a != 'index.js')) {
        console.log(`	<file src='${path}/${name}'/>`)
    }
})
