using System;

namespace ScienceBuddy
{
    /// <summary>
    /// Centralised password hashing and verification for the ScienceBuddy platform.
    /// Uses BCrypt for new accounts. Supports plain-text fallback for legacy data
    /// that has not yet been migrated (run Admin/MigratePasswords.aspx to convert).
    /// </summary>
    public static class PasswordHelper
    {
        /// <summary>
        /// Verifies a user-entered password against the stored value in the database.
        /// If the stored value is a BCrypt hash, BCrypt.Verify is used.
        /// If it is plain text (unmigrated), a direct case-sensitive comparison is used.
        /// </summary>
        public static bool VerifyPassword(string enteredPassword, string storedValue)
        {
            if (string.IsNullOrWhiteSpace(enteredPassword) || string.IsNullOrWhiteSpace(storedValue))
                return false;

            if (IsBCryptHash(storedValue))
            {
                try
                {
                    return BCrypt.Net.BCrypt.Verify(enteredPassword, storedValue);
                }
                catch
                {
                    // If the hash is malformed or the BCrypt library throws, deny access
                    return false;
                }
            }

            // Plain-text fallback: exact case-sensitive comparison (Ordinal = no culture rules)
            return string.Equals(enteredPassword, storedValue, StringComparison.Ordinal);
        }

        /// <summary>
        /// Hashes a new password using BCrypt before storing it in the database.
        /// Called during registration and password reset.
        /// </summary>
        public static string HashPassword(string newPassword)
        {
            if (string.IsNullOrWhiteSpace(newPassword))
                throw new ArgumentException("Password cannot be empty.");

            return BCrypt.Net.BCrypt.HashPassword(newPassword);
        }

        /// <summary>
        /// Checks whether the stored value looks like a BCrypt hash.
        /// BCrypt hashes always start with $2a$, $2b$, or $2y$ followed by cost factor.
        /// </summary>
        public static bool IsBCryptHash(string storedValue)
        {
            if (string.IsNullOrWhiteSpace(storedValue))
                return false;

            return storedValue.StartsWith("$2a$")
                || storedValue.StartsWith("$2b$")
                || storedValue.StartsWith("$2y$");
        }
    }
}
