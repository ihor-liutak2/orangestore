<#import "../layout.ftl" as layout>

<@layout.layout>
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h1 class="h3 mb-3 text-center">Вхід</h1>
                    <p class="text-muted text-center mb-4">
                        Увійдіть за допомогою email і пароля або через Google.
                    </p>

                    <div id="alertBox" class="alert alert-danger d-none" role="alert"></div>

                    <form id="loginForm">
                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input
                                    type="email"
                                    class="form-control"
                                    id="email"
                                    name="email"
                                    placeholder="you@example.com"
                                    required>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Пароль</label>
                            <input
                                    type="password"
                                    class="form-control"
                                    id="password"
                                    name="password"
                                    placeholder="••••••••"
                                    required>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-dark">Увійти</button>
                            <button type="button" id="googleLoginBtn" class="btn btn-outline-danger">
                                Увійти через Google
                            </button>
                        </div>
                    </form>

                    <div class="mt-4 text-center">
                        <a href="${contextPath!""}/user/forgot-password" class="d-block mb-2">
                            Забули пароль?
                        </a>
                        <span class="text-muted">Немає акаунта?</span>
                        <a href="${contextPath!""}/user/register">Зареєструватися</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import {
            getAuth,
            signInWithEmailAndPassword,
            GoogleAuthProvider,
            signInWithPopup
        } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";

        const app = initializeApp(window.appConfig.firebaseConfig);
        const auth = getAuth(app);

        const alertBox = document.getElementById("alertBox");
        const loginForm = document.getElementById("loginForm");
        const googleLoginBtn = document.getElementById("googleLoginBtn");

        function showError(message) {
            alertBox.textContent = message;
            alertBox.classList.remove("d-none");
        }

        function hideError() {
            alertBox.classList.add("d-none");
            alertBox.textContent = "";
        }

        async function sendTokenToBackend(user) {
            const idToken = await user.getIdToken();

            const response = await fetch(window.appConfig.contextPath + "/auth/session", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ idToken })
            });

            let payload = null;
            try {
                payload = await response.json();
            } catch (e) {
                // Ignore JSON parse errors and fall back to generic message.
            }

            if (!response.ok) {
                const errorMessage =
                    payload?.message ||
                    payload?.error ||
                    "Backend authentication failed";
                throw new Error(errorMessage);
            }

            return payload;
        }

        loginForm.addEventListener("submit", async (event) => {
            event.preventDefault();
            hideError();

            const email = document.getElementById("email").value.trim();
            const password = document.getElementById("password").value;

            try {
                const credential = await signInWithEmailAndPassword(auth, email, password);
                await sendTokenToBackend(credential.user);
                window.location.href = window.appConfig.contextPath + "/user/profile";
            } catch (error) {
                showError(error.message || "Не вдалося виконати вхід.");
            }
        });

        googleLoginBtn.addEventListener("click", async () => {
            hideError();

            try {
                const provider = new GoogleAuthProvider();
                const credential = await signInWithPopup(auth, provider);
                await sendTokenToBackend(credential.user);
                window.location.href = window.appConfig.contextPath + "/user/profile";
            } catch (error) {
                showError(error.message || "Не вдалося виконати вхід через Google.");
            }
        });
    </script>
</@layout.layout>