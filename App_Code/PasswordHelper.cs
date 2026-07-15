using System;

namespace ScienceBuddy
{
    /// <summary>
    /// Shared BCrypt password helper for consistent hashing and verification.
    /// </summary>
    public static class PasswordHelper
    {
        public static string HashPassword(string plainPassword)
        {
            if (string.IsNullOrWhiteSpace(plainPassword))
                throw new ArgumentException("Password cannot be empty.");
            return BCrypt.Net.BCrypt.HashPassword(plainPassword);
        }

        public static bool VerifyPassword(string plainPassword, string storedPasswordHash)
        {
            if (string.IsNullOrWhiteSpace(plainPassword) || string.IsNullOrWhiteSpace(storedPasswordHash))
                return false;
            try
            {
                return BCrypt.Net.BCrypt.Verify(plainPassword, storedPasswordHash);
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Checks if a stored password value is already a BCrypt hash.
        /// </summary>
        public static bool IsBCryptHash(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            return value.StartsWith("$2a$") || value.StartsWith("$2b$") || value.StartsWith("$2y$");
        }
    }
}
