const { CognitoJwtVerifier } = require('aws-jwt-verify');

const userPoolId = process.env.COGNITO_USER_POOL_ID;
const clientId = process.env.COGNITO_CLIENT_ID;

let verifier = null;
if (userPoolId && clientId) {
  verifier = CognitoJwtVerifier.create({
    userPoolId,
    tokenUse: 'access',
    clientId,
  });
}

async function authMiddleware(req, res, next) {
  if (!verifier) {
    return res.status(503).json({
      error: 'Auth not configured',
      message: 'COGNITO_USER_POOL_ID and COGNITO_CLIENT_ID must be set',
    });
  }

  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }

  const token = authHeader.substring(7);
  try {
    const payload = await verifier.verify(token);
    req.user = { sub: payload.sub, username: payload.username };
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

module.exports = { authMiddleware };
