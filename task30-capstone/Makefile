.PHONY: build up down logs status backup restore clean

build:
	@echo "🔨 Cloning directly from GitHub & Building Image..."
	docker compose build

up:
	@echo "🚀 Deploying Zero-Trust Architecture..."
	docker compose up -d

down:
	@echo "🛑 Tearing down stack safely..."
	docker compose down

logs:
	docker compose logs -f

status:
	docker compose ps

backup:
	@echo "💾 Dumping Database to backup.sql..."
	docker exec wp_git_db sh -c 'exec mariadb-dump --all-databases -uroot -p"$$MYSQL_ROOT_PASSWORD"' > backup.sql
	@echo "✅ Backup complete!"

restore:
	@echo "🔄 Restoring Database from backup.sql..."
	docker exec -i wp_git_db sh -c 'exec mariadb -uroot -p"$$MYSQL_ROOT_PASSWORD"' < backup.sql
	@echo "✅ Restore complete!"

clean:
	@echo "🧹 Removing volumes and orphaned images..."
	docker compose down -v
	docker image prune -f
