module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.js'],
  coverageDirectory: 'coverage',
  collectCoverageFrom: ['routes/**/*.js', 'app.js'],
  coveragePathIgnorePatterns: ['/node_modules/'],
};
