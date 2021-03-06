application loading
_reloadProjectNamed: projectName projectSpec: projectSpecOrNilOrString
	| specs metacello projectSpec repoDescription |

	projectSpecOrNilOrString
		ifNil: [
			specs := (self _globalNamed: 'Metacello') image
				baseline: [ :spec | spec name = projectName ];
				list.
			specs isEmpty
				ifFalse: [ projectSpec := specs first ] ]
		ifNotNil: [ 
			(projectSpecOrNilOrString isKindOf: CharacterCollection)
				ifTrue: [ repoDescription :=  projectSpecOrNilOrString. ]
				ifFalse: [ repoDescription := projectSpecOrNilOrString repositoryDescriptions first ] ].
	repoDescription
		ifNotNil: [
			self bannerLog: '		Reloading Project ', projectName, ' ', repoDescription printString.
			metacello := ((self _globalNamed: 'Metacello') new) 
				baseline: projectName;
				repository: repoDescription ]
		ifNil: [ 
			projectSpec notNil
				ifTrue: [
					self bannerLog: '		Reloading Project ', projectName printString.
					metacello := ((self _globalNamed: 'Metacello') image) 
						baseline: projectName;
						yourself ]
				ifFalse: [ self error: 'Project spec not found for ', projectName printString ] ].
	System commit. "commit so that reload failure can be debugged"
	self
		_deploy: [ 
		metacello onConflict: [ :ex :loaded :incoming | ex useIncoming ].
		metacello copy get.
		metacello copy load ].