-- Migration 010: Add username to users table

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;
