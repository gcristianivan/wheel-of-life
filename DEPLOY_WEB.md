# How to Deploy Wheel of Life to the Web

Since you cannot build Android apps locally, the best way to run this on your phone is via **GitHub Pages**.

## Steps

1.  **Push to GitHub**:
    -   Create a new repository on GitHub.
    -   Push this entire project code to that repository.
    
2.  **Enable GitHub Pages**:
    -   Go to your Repository **Settings**.
    -   Click on **Pages** (in the left sidebar).
    -   Under "Build and deployment", select **GitHub Actions** as the source.

3.  **Wait for Build**:
    -   Go to the **Actions** tab in your repository.
    -   You will see the "Deploy to GitHub Pages" workflow running.
    -   Once green (completed), click on the workflow run.
    -   You will find the **URL** to your live app under the "deploy" job or usually posted as a comment/status.
    
4.  **Open on Phone**:
    -   Visit that URL on your Android phone's Chrome browser.
    -   **Tip**: Tap "Add to Home Screen" in Chrome menu to make it look and feel like a real app!

## Note on "Base HREF"
The workflow automatically sets the base URL to `/${{ github.event.repository.name }}/`. If your repository is named `wheel-of-life`, your URL will be `https://your-username.github.io/wheel-of-life/`.
