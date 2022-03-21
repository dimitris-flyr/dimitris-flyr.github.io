(async function() {
    // Board page view
    const queryMatches = window.location.search.match(/selectedIssue=(\w+-\d+)/);
    // Main ticket page
    const pathnameMatches = window.location.pathname.match(/browse\/(\w+-\d+)/);
    const ticketID = queryMatches ? queryMatches[1] : pathnameMatches ? pathnameMatches[1] : "";
    if (!ticketID) {
        console.warn("No Jira ticket found in this page");
        return;
    }

    const issue = await jQuery.getJSON('/rest/api/3/issue/' + ticketID);
    const jiraTicketTitle = issue.fields.summary;
    const jiraTicketType = issue.fields.issuetype.name;
    
    const ticketToGithubTitle = {
        "bug": "fix",
        // add any other special mapping Jira to GitHub title here, apart from featrures
    };
    const githubPRType = ticketToGithubTitle?.[jiraTicketType] || "feat";
    const githubPRTitle =  `${githubPRType}: ${ticketID} ${jiraTicketTitle}`;
    
    const ticketToGithubBranch = {
        "bug": "hotfix",
        // add any other special mapping Jira to GitHub branch type here, apart from featrures
    };
    const githubBranchType = ticketToGithubBranch?.[jiraTicketType] || "feature";
    const branchTitle = jiraTicketTitle
                            .toLowerCase()
                            .replace(/[^a-z0-9]/g, "-") // Replace anything that is not alphanumeric with -
                            .replace(/\-+/g, '-') // Replace repeated -

    const githubBranch = `${githubBranchType}/${ticketID}-${branchTitle}`;
    
    prompt("Copy your branch name:", githubBranch);
    prompt("Copy your PR title:", githubPRTitle);
})()
