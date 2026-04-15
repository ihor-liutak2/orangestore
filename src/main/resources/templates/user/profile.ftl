<#import "../layout.ftl" as layout>

<@layout.layout>
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h1 class="h3 mb-0">Профіль користувача</h1>
                        <span class="badge text-bg-dark">${currentUserRole!"USER"}</span>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">ID</div>
                                <div>${currentUserId!""}</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Firebase UID</div>
                                <div>${currentFirebaseUid!""}</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Email</div>
                                <div>${currentUserEmail!""}</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Display name</div>
                                <div>${currentDisplayName!""}</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Provider</div>
                                <div>${currentAuthProvider!""}</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Role</div>
                                <div>${currentUserRole!""}</div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Email verified</div>
                                <div>
                                    <#if currentEmailVerified?? && currentEmailVerified>
                                        Так
                                    <#else>
                                        Ні
                                    </#if>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="border rounded p-3 bg-white">
                                <div class="text-muted small">Enabled</div>
                                <div>
                                    <#if currentUserEnabled?? && currentUserEnabled>
                                        Так
                                    <#else>
                                        Ні
                                    </#if>
                                </div>
                            </div>
                        </div>
                    </div>

                    <#if currentUserPhotoUrl?? && currentUserPhotoUrl?has_content>
                        <div class="mt-4">
                            <div class="text-muted small mb-2">Фото профілю</div>
                            <img src="${currentUserPhotoUrl}"
                                 alt="Profile photo"
                                 class="img-thumbnail"
                                 style="max-width: 180px;">
                        </div>
                    </#if>
                </div>
            </div>
        </div>
    </div>
</@layout.layout>