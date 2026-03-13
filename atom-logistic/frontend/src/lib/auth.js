import {
  CognitoUserPool,
  CognitoUser,
  AuthenticationDetails,
} from 'amazon-cognito-identity-js';

const poolData = {
  UserPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID || '',
  ClientId: import.meta.env.VITE_COGNITO_CLIENT_ID || '',
};

let userPool = null;
if (poolData.UserPoolId && poolData.ClientId) {
  userPool = new CognitoUserPool(poolData);
}

export function getCurrentUser() {
  if (!userPool) return null;
  return userPool.getCurrentUser();
}

export function getSession() {
  return new Promise((resolve, reject) => {
    const user = getCurrentUser();
    if (!user) {
      reject(new Error('No user'));
      return;
    }
    user.getSession((err, session) => {
      if (err) reject(err);
      else resolve(session);
    });
  });
}

export async function getAccessToken() {
  const session = await getSession();
  return session.getAccessToken().getJwtToken();
}

export function signIn(email, password) {
  return new Promise((resolve, reject) => {
    if (!userPool) {
      reject(new Error('Cognito not configured'));
      return;
    }
    const authDetails = new AuthenticationDetails({
      Username: email,
      Password: password,
    });
    const cognitoUser = new CognitoUser({
      Username: email,
      Pool: userPool,
    });
    cognitoUser.authenticateUser(authDetails, {
      onSuccess: (result) => resolve(result),
      onFailure: (err) => reject(err),
    });
  });
}

export function signUp(email, password, name) {
  return new Promise((resolve, reject) => {
    if (!userPool) {
      reject(new Error('Cognito not configured'));
      return;
    }
    userPool.signUp(email, password, [{ Name: 'name', Value: name || '' }], null, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });
}

export function confirmSignUp(email, code) {
  return new Promise((resolve, reject) => {
    if (!userPool) {
      reject(new Error('Cognito not configured'));
      return;
    }
    const cognitoUser = new CognitoUser({ Username: email, Pool: userPool });
    cognitoUser.confirmRegistration(code, true, (err) => {
      if (err) reject(err);
      else resolve();
    });
  });
}

export function signOut() {
  const user = getCurrentUser();
  if (user) user.signOut();
}

export function isConfigured() {
  return !!(poolData.UserPoolId && poolData.ClientId);
}
