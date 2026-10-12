component extends="org.lucee.cfml.test.LuceeTestCase" labels="postgres" {

	// keep in sync with pom.xml (mvnGroupId:mvnArtifactId:version)
	variables.mavenCoordinate = "org.postgresql:postgresql:42.7.11";

	function isNotSupported() {
		return isEmpty( server.getDatasource( "postgres" ) );
	}

	private boolean function luceeSupportsMavenJdbc() {
		try {
			return server.doesJDBCSupportMaven();
		}
		catch ( any e ) {
			return false;
		}
	}

	/**
	 * "bundle" loads the driver from the OSGi bundle, "maven" resolves it from Maven (this is the
	 * only way the lite extension, which does not ship the driver, can work)
	 */
	private array function getModes() {
		var modes = [ "bundle" ];
		if ( luceeSupportsMavenJdbc() ) arrayAppend( modes, "maven" );
		return modes;
	}

	private struct function getDS( required string mode ) {
		var ds = duplicate( server.getDatasource( "postgres" ) );
		if ( arguments.mode eq "maven" ) {
			structDelete( ds, "bundleName" );
			structDelete( ds, "bundleVersion" );
			ds.maven = variables.mavenCoordinate;
		}
		return ds;
	}

	private string function newTableName() {
		return "ldev_pgtest_" & lCase( replace( createUUID(), "-", "", "all" ) );
	}

	private void function dropTable( required struct ds, required string table ) {
		queryExecute( "DROP TABLE IF EXISTS #arguments.table#", {}, { datasource: arguments.ds } );
	}

	function run( testResults, testBox ) {
		for ( var mode in getModes() ) {
			describeMode( mode );
		}
	}

	private void function describeMode( required string mode ) {
		var mode = arguments.mode;

		describe( title="PostgreSQL JDBC driver (#mode#)", skip=isNotSupported(), body=function() {

			it( title="connects and reports the PostgreSQL server", body=function() {
				var ds = getDS( mode );
				var qry = queryExecute( "SELECT version() AS v", {}, { datasource: ds } );
				expect( qry.recordCount ).toBe( 1 );
				expect( qry.v ).toInclude( "PostgreSQL" );
			});

			it( title="reports the expected JDBC driver version", body=function() {
				var ds = getDS( mode );
				dbinfo datasource=ds name="local.info" type="version";
				expect( info.driver_name ).toInclude( "PostgreSQL" );
				// in bundle mode the version depends on the bundle installed in Lucee
				if ( mode eq "maven" ) expect( info.driver_version ).toInclude( listLast( variables.mavenCoordinate, ":" ) );
			});

			it( title="runs a query with a parameter against a table", body=function() {
				var ds = getDS( mode );
				var table = newTableName();
				try {
					queryExecute( "CREATE TABLE #table# ( id INTEGER, name VARCHAR(50) )", {}, { datasource: ds } );
					queryExecute(
						"INSERT INTO #table# ( id, name ) VALUES ( :id, :name )",
						{ id: { value: 1, cfsqltype: "cf_sql_integer" }, name: { value: "Susi", cfsqltype: "cf_sql_varchar" } },
						{ datasource: ds }
					);
					var qry = queryExecute( "SELECT name FROM #table# WHERE id = :id", { id: { value: 1, cfsqltype: "cf_sql_integer" } }, { datasource: ds } );
					expect( qry.recordCount ).toBe( 1 );
					expect( qry.name ).toBe( "Susi" );
				}
				finally {
					dropTable( ds, table );
				}
			});

		});
	}

}
