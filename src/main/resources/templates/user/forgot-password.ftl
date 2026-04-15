<#import "../layout.ftl" as layout>

<@layout.layout>
    <div class="row justify-content-center">
        <div class="col-md-6 col-lg-5">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h1 class="h3 mb-3 text-center">Відновлення пароля</h1>
                    <p class="text-muted text-center mb-4">
                        Введіть email, і Firebase надішле лист для скидання пароля.
                    </p>

                    <div id="alertBox" class="alert alert-danger d-none" role="alert"></div>
                    <div id="successBox" class="alert alert-success d-none" role="alert"></div>

                    <form id="forgotPasswordForm">
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

                        <div class="d-grid">
                            <button type="submit" class="btn btn-dark">Надіслати лист</button>
                        </div>
                    </form>

                    <div class="mt-4 text-center">
                        <a href="${contextPath!""}/user/login">Повернутися до входу</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
        import {
            getAuth,
            sendPasswordResetEmail
        } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";

        const app = initializeApp(window.appConfig.firebaseConfig);
        const auth = getAuth(app);

        const alertBox = document.getElementById("alertBox");
        const successBox = document.getElementById("successBox");
        const forgotPasswordForm = document.getElementById("forgotPasswordForm");

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

        forgotPasswordForm.addEventListener("submit", async (event) => {
            event.preventDefault();

            const email = document.getElementById("email").value.trim();

            try {
                await sendPasswordResetEmail(auth, email);
                showSuccess("Лист для скидання пароля успішно надіслано.");
            } catch (error) {
                showError(error.message || "Не вдалося надіслати лист для скидання пароля.");
            }
        });
    </script>
</@layout.layout>