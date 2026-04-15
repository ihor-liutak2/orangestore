<#import "../layout.ftl" as layout>

<@layout.layout>
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h1 class="h3 mb-3 text-center">Реєстрація</h1>
                    <p class="text-muted text-center mb-4">
                        Створіть новий обліковий запис OrangeStore.
                    </p>

                    <div id="alertBox" class="alert alert-danger d-none" role="alert"></div>
                    <div id="successBox" class="alert alert-success d-none" role="alert"></div>

                    <form id="registerForm">
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
                                    placeholder="Мінімум 6 символів"
                                    required>
                        </div>

                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">Підтвердження пароля</label>
                            <input
                                    type="password"
                                    class="form-control"
                                    id="confirmPassword"
                                    name="confirmPassword"
                                    placeholder="Повторіть пароль"
                                    required>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-dark">Зареєструватися</button>
                        </div>
                    </form>

                    <div class="mt-4 text-center">
                        <span class="text-muted">Вже маєте акаунт?</span>
                        <a href="${contextPath!""}/user/login">Увійти</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import {
            getAuth,
            createUserWithEmailAndPassword
        } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";

        const app = initializeApp(window.appConfig.firebaseConfig);
        const auth = getAuth(app);

        const alertBox = document.getElementById("alertBox");
        const successBox = document.getElementById("successBox");
        const registerForm = document.getElementById("registerForm");

        function showError(message) {
            alertBox.textContent = message;
            alertBox.classList.remove("d-none");
            successBox.classList.add("d-none");
        }

        function showSuccess(message) {
            successBox.textContent = message;
            successBox.classList.remove("d-none");
            alertBox.classList.add("d-none");
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
                // ignore
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

        registerForm.addEventListener("submit", async (event) => {
            event.preventDefault();

            const email = document.getElementById("email").value.trim();
            const password = document.getElementById("password").value;
            const confirmPassword = document.getElementById("confirmPassword").value;

            if (password !== confirmPassword) {
                showError("Паролі не співпадають.");
                return;
            }

            try {
                const credential = await createUserWithEmailAndPassword(auth, email, password);
                await sendTokenToBackend(credential.user);

                showSuccess("Реєстрація успішна. Зараз буде виконано перенаправлення.");

                setTimeout(() => {
                    window.location.href = window.appConfig.contextPath + "/user/profile";
                }, 1000);

            } catch (error) {
                showError(error.message || "Не вдалося виконати реєстрацію.");
            }
        });
    </script>
</@layout.layout>