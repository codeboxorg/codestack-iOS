.PHONY: gitignore-apply

gitignore-apply:
	@echo "🔍 Removing tracked files that should be ignored..."
	@set -e; \
	git ls-files --cached -i --exclude-standard | while read file; do \
	  git rm --cached "$$file" 2>/dev/null || echo "⚠️  Skipped (missing): $$file"; \
	done
	@echo "✅ .gitignore 적용 완료. 필요한 경우 커밋해 주세요."

add-deleted:
	@git restore --staged .
	@git ls-files --deleted -z | xargs -0 git add
	@echo "deleted file add"
	
	
