package com.oakam.launchdarkly_flutter;

import com.launchdarkly.sdk.LDUser;

import org.junit.Assert;
import org.junit.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;

public class LaunchdarklyFlutterPluginTest {

    private final LaunchdarklyFlutterPlugin plugin = new LaunchdarklyFlutterPlugin();

    @Test
    public void testUserAttributes() {
        final String userId = "testUserID";
        final String secondaryKey = "testSecondaryKey";
        final String avatar = "testAvatarUrl";
        final String country = "Test County";
        final String ip = "localhost";
        final String email = "test@test.com";
        final String name = "Test Full Name";
        final String firstName = "Test First Name";
        final String lastName = "Test Last Name";

        final LDUser expected = new LDUser.Builder(userId)
                .secondary(secondaryKey)
                .avatar(avatar)
                .country(country)
                .ip(ip)
                .email(email)
                .firstName(firstName)
                .lastName(lastName)
                .name(name)
                .build();

        final LDUser.Builder builder = new LDUser.Builder(userId);

        final Map<String, String> attributes = new HashMap<>();
        attributes.put("secondaryKey", secondaryKey);
        attributes.put("avatar", avatar);
        attributes.put("country", country);
        attributes.put("ip", ip);
        attributes.put("email", email);
        attributes.put("name", name);
        attributes.put("lastName", lastName);
        attributes.put("firstName", firstName);

        plugin.populateBuiltInAttributes(builder, attributes, new ArrayList<String>());

        Assert.assertEquals(expected, builder.build());
    }

    @Test
    public void testPrivateUserAttributes() {
        final String userId = "testUserID";
        final String secondaryKey = "testSecondaryKey";
        final String avatar = "testAvatarUrl";
        final String country = "Test County";
        final String ip = "localhost";
        final String email = "test@test.com";
        final String name = "Test Full Name";
        final String firstName = "Test First Name";
        final String lastName = "Test Last Name";

        final LDUser expected = new LDUser.Builder(userId)
                .privateSecondary(secondaryKey)
                .privateAvatar(avatar)
                .privateCountry(country)
                .privateIp(ip)
                .privateEmail(email)
                .privateFirstName(firstName)
                .privateLastName(lastName)
                .privateName(name)
                .build();

        final LDUser.Builder builder = new LDUser.Builder(userId);

        final Map<String, String> attributes = new HashMap<>();
        attributes.put("secondaryKey", secondaryKey);
        attributes.put("avatar", avatar);
        attributes.put("country", country);
        attributes.put("ip", ip);
        attributes.put("email", email);
        attributes.put("name", name);
        attributes.put("lastName", lastName);
        attributes.put("firstName", firstName);

        plugin.populateBuiltInAttributes(builder, attributes, new ArrayList<>(attributes.keySet()));

        Assert.assertEquals(expected, builder.build());
    }

    @Test
    public void testCustomAttributes() {
        final String userId = "testUserID";
        final String string = "string";
        final int integer = 10;
        final long longNumber = 10L;
        final double doubleNumber = 2.0;

        final LDUser expected = new LDUser.Builder(userId)
                .custom("string", string)
                .custom("integer", integer)
                .custom("long", longNumber)
                .custom("double", doubleNumber)
                .build();

        final LDUser.Builder builder = new LDUser.Builder(userId);

        final Map<String, Object> attributes = new HashMap<>();
        attributes.put("string", string);
        attributes.put("integer", integer);
        attributes.put("long", longNumber);
        attributes.put("double", doubleNumber);

        plugin.populateCustomAttributes(builder, attributes, new ArrayList<String>());

        Assert.assertEquals(expected, builder.build());
    }

    @Test
    public void testPrivateCustomAttributes() {
        final String userId = "testUserID";
        final String string = "string";
        final int integer = 10;
        final long longNumber = 10L;
        final double doubleNumber = 2.0;

        final LDUser expected = new LDUser.Builder(userId)
                .privateCustom("string", string)
                .privateCustom("integer", integer)
                .privateCustom("long", longNumber)
                .privateCustom("double", doubleNumber)
                .build();

        final LDUser.Builder builder = new LDUser.Builder(userId);

        final Map<String, Object> attributes = new HashMap<>();
        attributes.put("string", string);
        attributes.put("integer", integer);
        attributes.put("long", longNumber);
        attributes.put("double", doubleNumber);

        plugin.populateCustomAttributes(builder, attributes, new ArrayList<>(attributes.keySet()));

        Assert.assertEquals(expected, builder.build());
    }

    @Test
    public void testCreateUser() {
        final String userId = "testUserID";
        final String email = "test@test.com";
        final String customAttr = "customAttr";

        final LDUser expected = new LDUser.Builder(userId)
                .anonymous(false)
                .email(email)
                .privateCustom("privateCustom", customAttr)
                .build();

        final Map<String, String> userAttributes = new HashMap<>();
        userAttributes.put("email", email);

        final Map<String, Object> custom = new HashMap<>();
        custom.put("privateCustom", customAttr);

        final Map<String, Object> arguments = new HashMap<>();
        arguments.put("userKey", userId);
        arguments.put("custom", custom);
        arguments.put("user", userAttributes);
        arguments.put("privateAttributes", new ArrayList<>(custom.keySet()));

        final MethodCall methodCall = new MethodCall("identify", arguments);
        final LDUser actual = plugin.createUser(methodCall);

        Assert.assertEquals(expected, actual);
    }
}
