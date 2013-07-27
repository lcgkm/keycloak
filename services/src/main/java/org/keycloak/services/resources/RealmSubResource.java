package org.keycloak.services.resources;

import org.jboss.resteasy.logging.Logger;
import org.keycloak.representations.idm.PublishedRealmRepresentation;
import org.keycloak.services.models.RealmModel;
import org.picketlink.idm.IdentitySession;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;

/**
 * @author <a href="mailto:bill@burkecentral.com">Bill Burke</a>
 * @version $Revision: 1 $
 */
public class RealmSubResource {
    protected static final  Logger logger = Logger.getLogger(RealmSubResource.class);
    public static final String ADMIN_ROLE = "$REALM-ADMIN$";

    @Context
    protected UriInfo uriInfo;

    @Context
    protected IdentitySession identitySession;

    protected RealmModel realm;

    public RealmSubResource(RealmModel realm) {
        this.realm = realm;
    }

    public static UriBuilder realmUrl(UriInfo uriInfo) {
        UriBuilder base = uriInfo.getBaseUriBuilder()
                .path(RealmsResource.class).path(RealmsResource.class, "getRealmResource");
        return base;
    }

    @GET
    @Produces("application/json")
    public PublishedRealmRepresentation getRealm(@PathParam("realm") String id) {
        return realmRep(realm, uriInfo);
    }

    @GET
    @Path("html")
    @Produces("text/html")
    public String getRealmHtml(@PathParam("realm") String id) {
        StringBuffer html = new StringBuffer();

        String authUri = TokenService.loginPageUrl(uriInfo).build(realm.getId()).toString();
        String codeUri = TokenService.accessCodeToTokenUrl(uriInfo).build(realm.getId()).toString();
        String grantUrl = TokenService.grantAccessTokenUrl(uriInfo).build(realm.getId()).toString();
        String idGrantUrl = TokenService.grantIdentityTokenUrl(uriInfo).build(realm.getId()).toString();

        html.append("<html><body><h1>Realm: ").append(realm.getName()).append("</h1>");
        html.append("<p>auth: ").append(authUri).append("</p>");
        html.append("<p>code: ").append(codeUri).append("</p>");
        html.append("<p>grant: ").append(grantUrl).append("</p>");
        html.append("<p>identity grant: ").append(idGrantUrl).append("</p>");
        html.append("<p>public key: ").append(realm.getPublicKeyPem()).append("</p>");
        html.append("</body></html>");

        return html.toString();
    }


    public static PublishedRealmRepresentation realmRep(RealmModel realm, UriInfo uriInfo) {
        PublishedRealmRepresentation rep = new PublishedRealmRepresentation();
        rep.setRealm(realm.getName());
        rep.setSelf(realmUrl(uriInfo).build(realm.getId()).toString());
        rep.setPublicKeyPem(realm.getPublicKeyPem());
        rep.setAdminRole(ADMIN_ROLE);

        rep.setAuthorizationUrl(TokenService.loginPageUrl(uriInfo).build(realm.getId()).toString());
        rep.setCodeUrl(TokenService.accessCodeToTokenUrl(uriInfo).build(realm.getId()).toString());
        rep.setGrantUrl(TokenService.grantAccessTokenUrl(uriInfo).build(realm.getId()).toString());
        String idGrantUrl = TokenService.grantIdentityTokenUrl(uriInfo).build(realm.getId()).toString();
        rep.setIdentityGrantUrl(idGrantUrl);
        return rep;
    }


}
