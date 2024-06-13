const { exec } = require('child_process');

exports.handler = async (event) => {
  const command = 'docker run -d -e MYSQLDB_HOST=your-mysql-host -e MYSQLDB_USER=hiberus -e MYSQLDB_PASSWORD=123456789hiberus -e MYSQLDB_NAME=challenge-hiberus -e MYSQLDB_PORT=3306 myapp:1.0';

  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`exec error: ${error}`);
        reject(error);
      }
      console.log(`stdout: ${stdout}`);
      console.error(`stderr: ${stderr}`);
      resolve(stdout ? stdout : stderr);
    });
  });
};
