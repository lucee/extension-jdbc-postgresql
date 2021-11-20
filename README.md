# Lucee PostgreSQL JDBC Extension

[![Java CI](https://github.com/lucee/extension-jdbc-postgresql/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/extension-jdbc-postgresql/actions/workflows/main.yml)

Issues: https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20postgres

Manual Downloads: https://download.lucee.org/#671B01B8-B3B3-42B9-AC055A356BED5281

Note: Connection tests for older drivers have been disabled

We used the bundled Postgres 14 with GitHub Actions (it's built into the ubuntu image and thus is faster), the older JDBC driver don't support the new authentication method
