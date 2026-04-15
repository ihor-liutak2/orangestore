<#-- Base layout template -->
<#macro layout>
    <!DOCTYPE html>
    <html lang="uk">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${title!"OrangeStore"}</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
              rel="stylesheet"
              crossorigin="anonymous">
    </head>

    <body class="bg-light">

    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${contextPath!""}/hello">🍊 OrangeStore</a>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#navBar">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navBar">

                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${contextPath!""}/hello">Головна</a>
                    </li>
                </ul>

                <ul class="navbar-nav ms-auto">

                    <#if isAuthenticated?? && isAuthenticated>

                        <li class="nav-item">
                            <a class="nav-link" href="${contextPath!""}/user/profile">
                                ${currentDisplayName!currentUserEmail!"User"}
                            </a>
                        </li>

                        <li class="nav-item">
                            <button id="logoutBtn"
                                    class="btn btn-outline-light btn-sm ms-lg-2">
                                Вийти
                            </button>
                        </li>

                    <#else>

                        <li class="nav-item">
                            <a class="nav-link" href="${contextPath!""}/user/login">Вхід</a>
                        </li>

                        <li class="nav-item">
                            <a class="nav-link" href="${contextPath!""}/user/register">Реєстрація</a>
                        </li>

                    </#if>

                </ul>
            </div>
        </div>
    </nav>

    <main class="container py-4">
        <#nested>
    </main>

    <footer class="border-top py-3 bg-white">
        <div class="container text-muted small">
            OrangeStore © ${.now?string("yyyy")}
        </div>
    </footer>

    <#-- 🔥 Global app config -->
    <script>
        window.appConfig = {
            contextPath: "${contextPath!""}",

            firebaseConfig: {
                apiKey: "${firebaseWebApiKey!""}",
                authDomain: "${firebaseWebAuthDomain!""}",
                projectId: "${firebaseWebProjectId!""}",
                storageBucket: "${firebaseWebStorageBucket!""}",
                messagingSenderId: "${firebaseWebMessagingSenderId!""}",
                appId: "${firebaseWebAppId!""}",
                measurementId: "${firebaseWebMeasurementId!""}"
            },

            auth: {
                isAuthenticated: <#if isAuthenticated?? && isAuthenticated>true<#else>false</#if>,
                userId: "${currentUserId!""}",
                email: "${currentUserEmail!""}",
                displayName: "${currentDisplayName!""}",
                role: "${currentUserRole!""}",
                firebaseUid: "${currentFirebaseUid!""}",
                provider: "${currentAuthProvider!""}",
                emailVerified: <#if currentEmailVerified?? && currentEmailVerified>true<#else>false</#if>,
                enabled: <#if currentUserEnabled?? && currentUserEnabled>true<#else>false</#if>,
                photoUrl: "${currentUserPhotoUrl!""}"
            }
        };
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
            crossorigin="anonymous"></script>

    <#-- 🔐 Logout logic -->
    <#if isAuthenticated?? && isAuthenticated>
        <script type="module">
            import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
            import { getAuth, signOut } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";

            const app = initializeApp(window.appConfig.firebaseConfig);
            const auth = getAuth(app);

            const logoutBtn = document.getElementById("logoutBtn");

            if (logoutBtn) {
                logoutBtn.addEventListener("click", async () => {

                    try {
                        await signOut(auth);
                    } catch (e) {
                        console.error("Firebase logout failed", e);
                    }

                    await fetch(window.appConfig.contextPath + "/auth/logout", {
                        method: "POST"
                    });

                    window.location.href = window.appConfig.contextPath + "/user/login";
                });
            }
        </script>
    </#if>

    </body>
    </html>
</#macro>