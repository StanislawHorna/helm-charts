import sys

if "/etc/netbox/config" not in sys.path:
    sys.path.append("/etc/netbox/config")

SOCIAL_AUTH_OIDC_SCOPE = ["openid", "profile", "email", "groups"]


def configure_netbox_user_permissions(backend, user, response, *args, **kwargs):
    if backend.name != "oidc":
        return

    # Use NetBox's custom Group model instead of Django's default Group model
    import os
    from users.models import Group, ObjectPermission
    from django.contrib.contenttypes.models import ContentType

    user_groups = response.get("groups", [])

    # 1. Fetch or create NetBox Group using NetBox's Group model
    viewers_group, _ = Group.objects.get_or_create(
        name=os.getenv("AUTHENTIK_VIEWER_GROUP", "netbox-viewer")
    )

    # 2. Fetch or create Read-Only ObjectPermission
    perm_name = "Viewers - Global Read Only"
    obj_perm, created = ObjectPermission.objects.get_or_create(
        name=perm_name, defaults={"actions": ["view"]}
    )

    if created or not obj_perm.groups.filter(id=viewers_group.id).exists():
        obj_perm.actions = ["view"]
        obj_perm.groups.add(viewers_group)
        obj_perm.object_types.set(ContentType.objects.all())
        obj_perm.save()

    # 3. Superuser / Staff status check
    if os.getenv("AUTHENTIK_ADMIN_GROUP","netbox-admin") in user_groups:
        user.is_superuser = True
        user.is_staff = True
    else:
        user.is_superuser = False
        user.is_staff = False

    # 4. Bind user to viewer group if present in Authentik groups
    if os.getenv("AUTHENTIK_VIEWER_GROUP","netbox-viewer") in user_groups:
        user.groups.add(viewers_group)

    user.save()

SOCIAL_AUTH_BACKEND_ATTRS = {
    'oidc': ('Log in with Authentik', 'https://avatars.githubusercontent.com/u/82976448?s=500&v=4')
}
SOCIAL_AUTH_PIPELINE = (
    "social_core.pipeline.social_auth.social_details",
    "social_core.pipeline.social_auth.social_uid",
    "social_core.pipeline.social_auth.auth_allowed",
    "social_core.pipeline.social_auth.social_user",
    "social_core.pipeline.user.get_username",
    "social_core.pipeline.user.create_user",
    "social_core.pipeline.social_auth.associate_user",
    "social_core.pipeline.social_auth.load_extra_data",
    "social_core.pipeline.user.user_details",
    "authentik_pipeline.configure_netbox_user_permissions",
)
