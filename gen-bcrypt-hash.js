import bcrypt from 'bcryptjs';

async function hashPassword() {
  const password = 'admin123';
  const salt = await bcrypt.genSalt(12);
  const hash = await bcrypt.hash(password, salt);
  console.log(`Password: ${password}`);
  console.log(`Hash: ${hash}`);
}

hashPassword();