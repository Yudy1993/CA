# bi-challenge
## Scenario
You are a Senior Business Intelligence Analyst tasked with providing in-depth insights into client, market, agent, and case performance using SQL.

You have been provided with five datasets: clients.csv, cases.csv, case_won_events.csv, case_lost_events.csv, and case_opened_events.csv.

Your goal is to develop SQL queries that extract actionable intelligence to drive strategic decisions.

For each objective it's expected that you deliver simple notes about the result and a query to verify your findings.

Fell free to include graphs.

You must use the PostgreSQL dialect.

Don't hesitate to reach out if questions arise.

## Analysis Objectives (SQL Queries):
### Case insights
- Case Resolution Time - Measure the time it takes to resolve cases.
- Maximum case cost - Calculate the maximum a case must cost to run.

### Client insights
- Client Lifetime Value (CLTV) Segmentation - Calculate a simplified CLTV (sum of 'Won' case values) for each client and segment clients into high, medium, and low CLTV groups.
- Predictive Client Value - Develop a SQL query that attempts to predict a client's future case value (e.g., based on historical averages or trends). This can be a simplified prediction.

### Market insights
- Market trends - Calculate market trends, based on open, won and lost cases for each market.

### Agent (User) insights
- Agent Efficiency and Effectiveness - Analyze agent performance by considering both efficiency (time to resolve cases) and effectiveness (win rate) and identify high-performing agents.
- Agent Performance Over Time - Analyze how agent performance (win rate, resolution time) changes over time. Are there trends or patterns?

# Answers
## Guide  
- **data**: The files provided in the case  
- **models**: The models I generated  
- **visuals**: Graphs based on the data and models  
- **output_files**: Files related to the case as a csv. file
  
## Process  
To solve this case, I set up a local PostgreSQL server. I then queried the models using pgAdmin and established a connection to Power BI, where I built the graphs based on the models and underlying data.  

## Analysis Objectives (notes)  
### Case insights  
- **Case Resolution Time**: I aggregated both won and lost cases using a CTE and calculated the time from when a case was marked as "open" to when it was either "won" or "lost". The resolution time was then split into days and hours.  
- **Maximum Case Cost**: I may have misinterpreted this part slightly, as it was unclear what the cost of a case represented in the dataset. I assumed it related to a break-even point based on the value of won cases. I summed the values of won and lost cases, counted the number of open cases, and estimated the potential average value of the currently open cases.  

### Client insights  
- **Client Lifetime Value (CLTV) Segmentation**: I segmented clients based on their total number of won cases and calculated a percentile-based median to divide them into three tiers. Each tier was then assigned a descriptive label.  
- **Predictive Client Value**: I initially attempted to use the `monthly_prediction` model, applying historical averages to forecast future values. However, the dataset was too limited for this approach to provide significant insights. I then developed a more data-driven method that used monthly value, win rates, and case value to apply weighting for a more reliable prediction.  

### Market insights  
- **Market Trends**: I created a simple chart (available in the visuals folder) where I calculated and compared various rates. The chart lacks a time dimension or line chart format, but due to limited data, I decided this approach would best represent the trends without overcomplicating the visual.  

### Agent (User) insights  
- **Agent Efficiency and Effectiveness**: I built a model that calculated win rates and average resolution time for each agent.  
- **Agent Performance Over Time**: I used the `agent_performance_patterns` model to attempt tracking weekly performance and building a ranking system. Although I did not create a visual for this, I processed the raw data to produce a monthly chart instead. This chart reveals performance trends between agents.  

  Key insight: `user_1` appears to be a strong performer and likely one of the best agents. However, there's notable competition — as shown in the agent insights graph — where `user_3` outperformed all other agents in March based on the value of won cases. Furthermore, `user_3` shows an improving trend, while the performance of other agents declines slightly over the months.
