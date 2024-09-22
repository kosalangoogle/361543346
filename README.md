Looker Developer Guidelines
======
## Table of contents
- [Video Onboarding](#video-onboarding)
- [Looker Educational Resources](#looker-educational-resources)
- [Code Guide](#code-guide)
- [Folder Structure](#folder-structure)
- [Git Workflow](#git-workflow)
- [Optimising BigQuery Performance](#optimising-bigquery-performance)

## Video Onboarding
Video introduction to the Looker development environment. Password: Fatburen123
- [Introduction to Looker IDE](https://www.loom.com/share/b10446aed3664888be4d50ad37d28588)
- [Schema folder](https://www.loom.com/share/a905c363dd1a487ca30cc45b0c5a7992)
- [Create view from Table in schema folder](https://www.loom.com/share/b3a1c2a3d645461aabfc08429e9971fa)
- [Refinement layer - views](https://www.loom.com/share/5c9a1e2218d242c0b06d31369e6b483b)
- [Refinement layer - explores](https://www.loom.com/share/bab5b49cf1704b2c80aa48cb2ba9c569)
- [Referencing explores in prod.model](https://www.loom.com/share/1e9241244be4465e86aa8ae9ea777dbb)
- [Features folder](https://www.loom.com/share/06881639b3fd4ecdabd3fad21cf4cb5f)
- [All other files in the Looker development environment](https://www.loom.com/share/2a928306f6bc424197c22d92c51c2764)
- [View files in schema folder](https://www.loom.com/share/41a067dd85364a93b52fb617586e8376)
- [View files in refinement layer](https://www.loom.com/share/117a9679722548bd9888115dd10dd38f)
- [Explore files in refinement layer](https://www.loom.com/share/42abb2c0cfd24babb22d29d9bae252c4)

## Looker Educational Resources

| **Title**                                                                                                 | **Description**                                                         | **Time investment**   | **Price**   |
|---------------------------------------------------------------------------------------------------------  |-----------------------------------------------------------------------  |---------------------  |-----------  |
| [Looker Connect: LookML Track](https://connect.looker.com/)                                               | Looker's interactive tutorial for LookML developers   | 7 hours               | Free        |
| [Developing Data Models with LookML](https://www.coursera.org/learn/developing-data-models-with-lookml)   | Coursera course on developing with LookML                               | 6 hours               | Free        |
| [Epidemic Sound Data Modelling and Looker Upskilling Program](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/3515646165/Data+Modelling+and+Looker+Upskilling+Program)     | In-house Upskilling Programme aimed at Looker developers, focusing on data modelling and efficiency  | 6 hours               | Free |

## Red lines for Analytics Products and the Analytics Platform
When developing Looker Explores, Looks or Dashboards, consider them products that need to comply with a series of requirements.
<br>
The following table lists the 5 most important ones, what they mean in practice and a "Red Line" check that you should make before committing any code to this repository. The "Red Line" checks are also required in the PR template of our [Git Workflow](#git-workflow).

| **Product requirement**             | **Meaning in practice**                                              | **Red line criteria in a Looker context**                                                       |
|--------------------------------------|----------------------------------------------------------------------|-----------------------------------------------------------------------------|
|  1. Good user experience             | The business user can get answers within useful time                 | It takes < 2 minutes to load the final Dashboard or Look                |
|  2. Scalable and economically viable | DWH costs stay reasonable relative to business value offered         | The data pipeline of any explores added or edited process less than 1TB per day                               |
|  3. Easy to maintain                 | Maintaining existing code does not consume all productive time       | The data pipeline of any explores added or edited take less than 1 hours to run |
|  4. Versatile                        | Code is well documented, easy to change and extend to more use cases | The data pipeline of any explores added or edited is designed in a way that can cover > 1 relevant use case |
|  5. Reliable                         | Complete data quality / integrity test coverage                      | The data pipeline of any explores added or edited is covered with uniqueness tests in dbt |

To read how you to measure compliance with each of these requirements in practice and additional questions to ask, please refer to the [Red lines Confluence Page](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/3530358801/Best+practices+for+Data+Modelling+on+our+Analytics+Platform#Red-lines-for-Analytics-Products-and-their-Data-Pipelines)

## Code Guide

### LookML Coding Fundamental Rules

Certain rules are essential for the reliability and versatility of the looker data model and to avoid building up compounding technical debt.

- **Explores**: Explore label must contain one of the following emojis [✅⚠️⛔️]. Emojis are needed as flags to indicate to users whether the data is trustworthy to avoid business decisions being made based on faulty data
- **Explores**: Explore must have a description. Allow both users as well as developer understand the purpose of the explore
- **Explores**: Explore must have a `group_label` that is one of `Core Experience`, `Growth`, `Main`, `Music`, `Partnerships & DRM`, `Central Teams`. The label needs to clearly state the ownership of a specific explore for maintenance purposes. Ownership
- **Explores & Joins**: Joins must state a relationship parameter. If the relationship parameter for a join is omitted, Looker will use a default relationship of `many_to_one`. However, it's better to define the relationship explicitly so that developers scanning the code can quickly understand the join. Explicitly defining the relationship can also help prevent errors caused by mistyping or using the wrong columns in the join condition.
- **Views & Primary Keys**: Views must define a primary key so that any Explores that reference them can take advantage of symmetric aggregates and join them properly to views. This rule only applies to views that have defined a `sql_table_name` or `derived_table` parameter. If the view does not have a natural primary key (unique column), create a surrogate key by concatenating a unique combination of columns in your view. Preferrably add such a "surrogate key" in the dbt materialisation, using the macro `dbt_utils.generate_surrogate_key()` and adding a corresponding uniqueness test. For PDTs or DTs, use a `concat()` SQL statement in the SQL definition.
- **Views & Primary Keys**: The primary key should be listed first in a view so developers quickly understand the grain of the view and what a single record represents.
- **Views**: To be defined in snake case. View names should match the conventional format, which is snake case—words in lowercase, separated by underscores. For example, `all_orders` instead of `allOrders` or `AllOrders`.
- **Views**: Views should not have the same `sql_table_name` because two views with the same table name are effectively the same view. Instead, consolidate these views into a single view.
- **Dimensions**: To be defined in snake case. Dimension names should match the conventional format, which is snake case—words in lowercase, separated by underscores. For example, `order_id` instead of `orderId` or `OrderID`.
- **Measures**: To be defined in snake case. Measure names should match the conventional format, which is snake case—words in lowercase, separated by underscores. For example, `count_orders` instead of `OrderCount`.
- **Measures**: Measures should not directly reference table columns, but should instead reference dimensions that reference table columns, e.g. use `{dimension_field}` from the `1_schema layer`, not `{TABLE}.dimension_column_name`. This way, the dimension can be a layer of abstraction and single source of truth for all measures that reference it.

Please refer to the documentation on these [Fundamental Rules](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/2513174616/Looker+Developer+Guidelines#The-fundamental-rules) for a more detailed definition, their rationale and directories for which they apply.

Note that following these rules is mandatory and enforce through a Spectacles linter check that runs upon creating a Pull Request (more on that under [Git Workflow](#git-workflow)).

### LookML Coding Best practice

Beyond the Fundamental Rules, there are best practices for writing LookML code that help other developers understand your code and logic. These rules are not strictly enforced in the Spectacle linter check, but make sure that your code can be changed, maintained and reused by others.

- **Explores & Views**: Place include statements on top of the file. This helps other developers understand upstream dependencies.
- **Explores**: Help business users self serve by adding [Quick Starts](https://epidemicsound.cloud.looker.com/projects/epidemic-dwh/files/6_documentation/quick_starts.md) - they provide helpful guidance to users when getting familiar with a new explore.
- **Explores**: Declare fields included - when fields are explicitly defined, LookML developers can easily identify the fields included in the Explore without having to reference the view file or loading the Explore page
- **Explores**: Explores should define a label to provide a user-friendly name for the Explore in menus. Looker generates title-cased names for Explores based on the name in LookML, but these names aren't always useful for users. For example, an auto-generated Explore name Prod Sessions L3d (generated from explore: `prod_sessions_l3d`) is not as succinct or informational as Web Sessions.
- **Include statements**: Including all views using a wildcard (e.g. `*.view`) slows down LookML compilation and validation. Instead, explicitly include the specific views that you need.
- **Views**: If contains one view object, file name should be same as view object.
- **Views**: Views should only ever refer to the `epidemic-dwh-prod.analytics`  and `epidemic-dwh-prod.analytics_pii` datasets. If data is not available there, but is available in the data lake, please create a dbt materialisation in one of the beforementioned datasets.
- **Persistent Derived Tables (PDTs)**: Views that define persistent derived tables should be prefixed with `_pdt_` to make it easy to identify views based on Persistent Derived Tables.
- **Derived Tables (DTs)**: Views that define derived tables should be prefixed with `_dt_` to make it easy to identify views based on Derived Tables.
- **Persistent Derived Tables (PDTs) and Derived Tables (DTs)**: The table name in the `FROM` statement should explicitely state the BigQuery project and dataset, e.g. `epidemic-dwh-prod.dwp_pii.web_and_mobile_events` - otherwise it will default to the project billing and caching dataset `es-looker-prod-0514.looker_scratch`.
- **Measures**: Add `m_` as a prefix for any measure (e.g. `fact_subscription.m_ants`). This helps with picking it out of dropdowns and ensuring you don’t reference a dim instead of a measure in lookml
- **Measures**: Label the measure so users understand the type of aggregation (e.g. a type: sum is labeled as `m_total_`, an average measure should start with `m_avg_` or `m_average_`)
- **Dimensions**: Label YesNo dimensions to start with `is_` or `has_` so they are easier to understand
- **Dimensions**: Dimensions that refer to other dimensions should always refer to their substitution parameter, not the underlying column e.g. use `{dimension_field}` from the `1_schema layer`, not `{TABLE}.dimension_column_name`. This way, the `1_schema layer` dimension can be a layer of abstraction and single source of truth for all dimensions that reference it.
- **Dimensions**: Dimensions that are only used as a basis to create metrics and are not useful to the end business user should always be hidden.
- **Dimensions**: Visible dimensions should have descriptions
- **Parameters/Filters**: Add `p_` as a prefix for parameters.
- **Parameters/Filters**: Add `f_` as a prefix for filters.

### Code examples
- [Access Grants](https://epidemicsound.cloud.looker.com/projects/epidemic-dwh/files/6_documentation/access_grants.md)
- [Dynamic Timeframes](https://epidemicsound.cloud.looker.com/projects/epidemic-dwh/files/6_documentation/dynamic_timeframes.md)
- [Quick Starts](https://epidemicsound.cloud.looker.com/projects/epidemic-dwh/files/6_documentation/quick_starts.md)

## Code ownership
### How to determine code ownership for explores
- Code ownership is defined on a domain / team level by the `CODEOWNERS` file in this repository for each of the explores in the `2_refinement_layer/explores` directory.
- We use github team handles to identify a specific domain / team, e.g. `@epidemicsound/core-analytics` to identify explores owned by Core Analytics.
- We have some legacy explores that live outside the `2_refinement_layer/explores` directory and therefore do not have a clear owner defined via the `CODEOWNERS` file. For these explores, instead of adding each individual explore path to the `CODEOWNERS` file, we rely on the `group_label` parameter of each **explore** which allows us to reliably identify a team / domain owner (this is enforced by our Linter). We aim to move these explores to the standard folder structure within reasonable time.

### How to determine code ownership for views
We do not have a direct ownership defined for each view via the `CODEOWNERS` file. Use the following steps in descending order to identify ownership:
1. **Ownerhship inherited by explore**: If the view is used by one exclusive explore, then the view inherits the explore ownership.
2. **Ownership inherited from the Data Warehhouse / dbt**: If the view is used by more than one explore, for views that are auto-generated, the view inherits the ownership from the owner of the corresponding dbt model.
3. **Ownership inherited by creator**: If the view is used by more than one explore and is based on a PDT or DT, the view inherits the ownership from the team / domain of the original creator according to Github.
4. **Ownership inherited by last editor**: If the view is used by more than one explore and is based on a PDT or DT and cannot be allocated to a team / domain based on the original creator, the view inherits the ownership from the team / domain of the latest editor according to Github.

We aim to simplify this methodology to in the future.

### What it means to own code
Owning an explore means the analytics domain will need to deal with any issues that are directly related to that explore, in particular but not limited to any breach of the [ Red lines for Analytics Products and the Analytics Platform](#red-lines-for-analytics-products-and-the-analytics-platform).
That includes for example fixing broken SQL references or Data Warehouse performance issues.


## Folder and file structure
Note that the `1_schema` subfolder structure is aligned with the Data Warehouse Schema while the `02_refinement_layer` reflects the Analytics Domain structure.
- **Schema**: Only schema files generated through the [**Create View from Table**](https://docs.looker.com/data-modeling/getting-started/model-development#adding_a_new_view_from_an_existing_database_table) option. These should **not** be edited as they need to be able to be recreated to reflect changes in the Data Warehouse schemas
- **Refinement layer**: View and explore files. Add any refinements to the schema files here. Name any views in this layer with a `.layer.lkml` file extension. This file extension has the same functionality as a `view.lkml` file, but makes it easier for other developers to understand they are looking at the refinement of a view. Use separate files for explores and views, with the only exception being explores whose only purpose is to unnest fields in a view - these may live in the same file as the view.
- **Features**: Any files that don't adhere to the above structure with schema, view and explores in *separate files*
- **Derived Tables**: View files that contain Derived Tables (DTs) or Persistent Derived Tables (PDTs), auto-generated by placing the SQL statement in the [SQL Runner](https://epidemicsound.cloud.looker.com/sql?toggle=dat,sql) and extracting the *Derived Table LookML* - refer to the [documentation](https://cloud.google.com/looker/docs/sql-runner-create-derived-tables) for a detailed guide. Any edits or refinements of the view containing the PDT or DT (other than the name of the view) should be placed as a refinement in the  `2_refinement_layer` directory. Important: please consult the [Performance consideration for materialization strategy](#Performance-consideration-for-materialization-strategy) before adding any new PDTs.**
- **Documentation**: Markdown files for documentation
- **README.md**: Developer guidelines
- **manifest.lkml**: Constants that can be used across the whole Looker environment
- **prod.model**: Any explore file needs to be referenced here to be visible in production

```text
1_schema/
├── analytics/
├── analytics_pii/
└── other/
2_refinement_layer/
├── explores/
│   ├── core/
│   ├── drm/
│   ├── growth/
│   ├── main/
│   ├── music/
│   ├── other/
│   └── partnerships/
└── views/
    ├── analytics/
    ├── analytics_pii/
    └── other/
3_features/
4_derived_tables/
├── derived_tables/
└── persistent_derived_tables/
5_documentation/
```

## Git workflow
The Looker IDE is version controlled on [GitHub](https://github.com/epidemicsound/epidemic-dwh-looker). Pull Requests with Hard CI checks and formal peer reviews are required to merge your changes into the main branch.

### Before you start your work

Create a new branch in Looker for each task. Typically, each developer task is related to a single issue or user story which helps signal when a new branch is needed and when that branch can be deleted (e.g., when the issue is closed, the feature has been deployed).

Note that your personal development branch (which looks something like `dev-firstname-lastname-tvwd`) should **only** be used as a sandbox for you to test code locally, never to push code to the remote repo.

Before you begin development work, ensure the branch you are using is up to date with the main branch. If it is not, looker will display the “Pull Remote Changes” button on the top right corner. Once you click it, your branch will be up to date.

#### Naming convention for branches
- Start with the jira reference, e.g. `EP-29296`, followed by a “/”
- Prefix branch names with the purpose of the development work
- `feature/`  # adding a new view, metric, explore, etc.
- `fix/` # fixing existing data products because they are faulty or broken
- `update/` # updating the definition of a metrics or the business logic used
- `refactor/` # not altering the functionality of the code but altering it so it follows the best practices and is easier to work with
- Follow up with a brief description of the work and use “-” for spaces

| **Good branch naming**                                                   | **Bad branch naming**                                                            |
|------------------------------------------------------------|--------------------------------------------------------------------|
| EP-29296/**feature**/sales-dashboard                       | incl_new_report_for_stakeholders                                   |
| EP-29297/**fix**/marketing-dashboard-table-calcs           | important_updates_requested_by_stakeholders                        |
| EP-29297/**update**/dashboard-color-palettes               | sprint-4-development-work-include-a-new-feature-for-the-sales-team |
| EP-29673/**refactor**/cleaning-up-unused-folders-and-files |                                                                    |

### During your work
- Commit changes in logical chucks
- Avoid committing multiple unrelated tasks in the same commit
- Document your reasoning in the code as comments - this will allow others to build on your work
- Open pull requests can be opened in draft state to get early feedback, no expectation that it's ready to be merged. This is helpful to run the Spectacles Style Validator at an early stage to avoid having to refactor your contribution at a later stage.

### When you are done with your work
- Convert your Draft Pull Requests to a Pull Request
- Request a peer reviews. If you make changes to code owned by other developers, their review is required. To determine ownership, see the [section on code ownership](#code-ownership-and-what-it-means-in-practice)
- To get a Pull Request review from the Analytics Engineering team, create a Pull Request and add team members from Analytics Engineering as reviewers. There is a daily process to ensure your Pull Request gets allocated to one Analytics Engineer - you do not need to reach out to individual team members.
- Pull Requests should comply with all checks for the [Red lines for Analytics Products and the Analytics Platform](#red-lines-for-analytics-products-and-the-analytics-platform) have
- Pull Requests should include a brief summary on the change and any context needed
- Pull Requests needs to pass [Spectacles](https://app.spectacles.dev/) checks on 1. SQL Validity 2. Content Validity and 3. Coding Style before they can be merged with the `main` branch and be deployed to production
- The **SQL Validity Check** tests whether the SQL in the files you have edited is valid.
- The **Content Validity Check** tests whether the files you have edited cause any existing Looker content (Looks, Dashboards) to break.
- The **Coding Style Check** tests whether the [Fundamental Rules](#fundamental-rules) are complied with. If your code has Fundamental Code Style errors, resolve them using guidance [here](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/2513174616/Looker+Developer+Guidelines#How-to-address-fundamental-style-issues)
- If you need to access to Spectacles, reach out to [#looker-development](https://es.slack.com/archives/C01RUR3NY9M)
- Once reviewed and approved, the author of the PR must do the merge
- You do not need to remove any branches - they are automatically cleaned-up after merging the changes to the `main` branch.

## Optimising BigQuery performance
### Performance consideration for materialization strategy
One of the most common questions with regards to Looker development is when and where to materialize data transformations / tables. The two most relevant options for materialization in our current analytics stack with Looker and dbt are:
- [dbt models](https://github.com/epidemicsound/dbt)
- [Persistent Derived Tables](https://cloud.google.com/looker/docs/derived-tables#persistent-derived-tables) defined as SQL Queries within the LookML definition of a view. They are saved along with Looker cache in the Looker Scratch schema in BigQuery and refreshed in line with our cache strategy (every 24 hours or on new data available in epidemic-dwh-prod.analytics).

For a complete documentation of materialisation options and how to choose between them, please visit [Choosing between Looker and dbt materialisation options for your data transformation](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/3530358801/Data+Modelling+for+Analytics+Product+-+Best+practices+and+guidelines#Choosing-between-Looker-and-dbt-materialisation-options-for-your-data-transformation). Below some guidance for a quick decision:

| **Use dbt**                                                           | **Use Looker**                                                                                                                                                                   |
|-------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| For tried & tested use cases                                      | For small data transform to quickly iterate a POC (A POC is more than an ad-hoc data pull. At least one clearly defined, recurring use case that still needs to find its final form.) |
| Your transform processes >50GB -> move to a incremental dbt model | If the transformed data is only relevant in looker                                                                                                                           |
| If the transformed data also has a use case outside looker        |                                                                                                                                                                              |
| If you are not sure which materialization to choose               |                                                                                                                                                                              |

### Performance consideration when writing your data transformation query
Wherever your data transform may be materialized, optimise your query before your deploy it. It will ensure you offer both a good user experience (short runtime), as well as keeping scalable and economically viable. It is important to keep in mind not only the cost for running your transform, but also the reduction in data achieved by it, i.e. the cost to read from the result set.

#### Before you start your work
- Understand all crucial use cases
- Ask specific questions to set the scope for your data pipeline (e.g.why do you need data from 2014? why do you need this event type?)

#### During your work
- Have you added partitions and clusters to all large BigQuery Tables and PDTs? Note that this is key as otherwise any filters applied in your dashboards or looks *will not reduce the amount of data processed* by the query run in the Data Warehouse. In particular when defining large PDTs, make sure to add `partition_key` and `cluster_key` attributes to the `derived_table()` definition.
- Check whether the query complies with the [Red Line](#red-lines-for-analytics-products-and-the-analytics-platform) for data processed - use the [Query Execution Graph](https://cloud.google.com/bigquery/docs/query-insights#view_query_execution_details) to find the heavy load in your query
- Are all partitions and columns actually used in the final Dashboard, Look or Explore or could you potentially prune / remove some?
- Enforce conditional [filters](https://cloud.google.com/looker/docs/reference/param-explore-conditionally-filter) in your explore

#### When you are done with your work
- Check unused fields & partitions (the [History Explore](https://epidemicsound.cloud.looker.com/explore/system__activity/history) is helpful for that purpose)
- Monitor usage relative to cost with the [BQ Data Processed Estimation](https://cloud.google.com/bigquery/docs/estimate-costs) and [BQ Price Calculator](https://cloud.google.com/products/calculator/)
- Delete unused explores and their Data Pipelines

You can find more details in the section on [Optimising your transform](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/3530358801/Best+practices+for+Data+Modelling+on+our+Analytics+Platform#Optimising-your-transform)

### Performance consideration when building explores
For user experience and scalability, it is crucial to optimise your explores for database performance. Find below some recommendations to follow:
- Avoid `many-to-many` joins if at all possible as they are costly
- Move from the most granular level to the highest level of detail (`relationship: many_to_one`)
- Make sure the view at the base of the explore has partitions and clustering
- Use as few chained joins as possible (≤ 3 chained joins)
- No joining on primary keys concatenated in Looker
- Use primary keys properly

Visit the [Best Practices for Data Modelling in Looker](https://epidemicsound.atlassian.net/wiki/spaces/DP/pages/3540222009/Best+practices+for+Data+Modelling+in+Looker) for more recommendations.

### Performance consideration when building dashboards
To create a great performance experience for end users and save Data Warehouse cost, there are a few tips when designing Looker dashboards:

- **Optimizing the underlying query performance matters:** each dashboard element, when not returned from the cache, runs a SQL query that takes time to execute on the underlying database.
- **Limit the number of dashboard elements:** avoid creating dashboards with 25 or more queries. Keep dashboard performance slick by creating links and navigations between dashboards or [by creating links to custom URLs](https://help.looker.com/hc/en-us/articles/360001288228-Custom-Drilling-Using-HTML-and-Link) to create curated navigation from dashboard to dashboard.
- **When using [autorefresh](https://docs.looker.com/dashboards/editing-user-dashboards#dashboard_auto_refresh) in the dashboard**, ensure that the refresher frequency is not higher than the ELT process. We recommend using daily refresh on each element in the dashboard if it is not real-time monitoring.
- **Memory-consuming practice** includes: pivoted dimension, having many rows and columns, etc, so try to avoid pivoting high cardinality fields and limit the returned result in the element.
