const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// Compile TypeScript files for deployment
console.log('Compiling TypeScript files for production...');

// Create a tsconfig file for production
const tsConfig = {
  compilerOptions: {
    target: "es2018",
    module: "commonjs",
    esModuleInterop: true,
    skipLibCheck: true,
    forceConsistentCasingInFileNames: true,
    outDir: "./dist",
    rootDir: ".",
    strict: true,
    baseUrl: ".",
    paths: {
      "@shared/*": ["shared/*"]
    }
  },
  include: ["server/**/*.ts", "shared/**/*.ts"]
};

fs.writeFileSync('tsconfig.json', JSON.stringify(tsConfig, null, 2));

// Install TypeScript for compilation
exec('npm install typescript --no-save', (error, stdout, stderr) => {
  if (error) {
    console.error(`TypeScript installation error: ${error}`);
    return;
  }
  
  console.log('TypeScript installed. Compiling...');
  
  // Compile TypeScript
  exec('npx tsc', (error, stdout, stderr) => {
    if (error) {
      console.error(`Compilation error: ${error}`);
      return;
    }
    
    console.log('TypeScript compilation complete.');
    console.log('Setup the application by following these steps:');
    console.log('1. Create a .env file with your database credentials');
    console.log('2. Run "npm install" to install dependencies');
    console.log('3. Run "npm start" to start the application');
  });
});