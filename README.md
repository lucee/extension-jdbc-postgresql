# Lucee PostgreSQL JDBC Extension

[![Java CI](https://github.com/lucee/extension-jdbc-postgresql/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/extension-jdbc-postgresql/actions/workflows/main.yml)

Issues: https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20postgres

Note: Connection tests for older drivers have been disabled

We used the bundled Postgres 14 with GitHub Actions (it's built into the ubuntu image and thus is faster), the older JDBC driver don't support the new authentication method
