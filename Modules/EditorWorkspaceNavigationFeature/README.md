








Design Note
-----------
-	Workspace must be a document bundle.
-	All files must be inside of the bundle.
-	Externalised project will be supported later when requested.
	-	Need to add `location` property to workspace configuration file.
	-	Workspace will open the location instead of document bundle location.
	-	You still cannot link files out of the overriden location.
		All workspace files are related to workspace location root, and must be
		contained in the location.
	-	Editor does not differentiate symlinks. So you can use external files 
		using symlink. Anyway keeping the symlink validity is your responsibility.






Dialogue Styling
----------------
-	Use *error* for issues that REQUIRES manual user handling.
	program failed to perform atomic operation in atomic manner.
	Integrity of user's mental data-set should be inconsistent with actual 
	program state, and user need to handle the failure manually to recover 
	integerity.

-	Use *warning* for issues that needs user attention, but does not break user's
	mental data-set. Mental data-set is synchronised with program state.