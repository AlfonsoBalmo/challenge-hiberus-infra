const { exec } = require('child_process');

exports.handler = async (event) => {
    const { MYSQLDB_HOST, MYSQLDB_USER, MYSQLDB_PASSWORD, MYSQLDB_NAME, MYSQLDB_PORT } = process.env;

    const dockerRunCommand = `
      docker run --name myapp \
      -e MYSQLDB_HOST=${MYSQLDB_HOST} \
      -e MYSQLDB_USER=${MYSQLDB_USER} \
      -e MYSQLDB_PASSWORD=${MYSQLDB_PASSWORD} \
      -e MYSQLDB_NAME=${MYSQLDB_NAME} \
      -e MYSQLDB_PORT=${MYSQLDB_PORT} \
      -p 8080:8080 -d myapp:1.0
    `;

    return new Promise((resolve, reject) => {
        exec(dockerRunCommand, (error, stdout, stderr) => {
            if (error) {
                console.error(`exec error: ${error}`);
                reject(error);
            }
            console.log(`stdout: ${stdout}`);
            console.error(`stderr: ${stderr}`);
            resolve(stdout);
        });
    });
};
