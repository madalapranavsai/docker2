CREATE TABLE IF NOT EXISTS system_status (
    id SERIAL PRIMARY KEY,
    service VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL
);
INSERT INTO system_status (service, status) VALUES ('Database', 'Online');
