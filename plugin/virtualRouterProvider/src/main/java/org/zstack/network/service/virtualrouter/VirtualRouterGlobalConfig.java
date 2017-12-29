package org.zstack.network.service.virtualrouter;

import org.zstack.core.config.GlobalConfig;
import org.zstack.core.config.GlobalConfigDefinition;
import org.zstack.core.config.GlobalConfigValidation;

/**
 */
@GlobalConfigDefinition
public class VirtualRouterGlobalConfig {
    public static final String CATEGORY = "virtualRouter";

    @GlobalConfigValidation
    public static GlobalConfig DEPLOY_AGENT_ON_START = new GlobalConfig(CATEGORY, "agent.deployOnStart");
    @GlobalConfigValidation
    public static GlobalConfig COMMANDS_PARALELLISM_DEGREE = new GlobalConfig(CATEGORY, "command.parallelismDegree");
    @GlobalConfigValidation
    public static GlobalConfig RESTART_DNSMASQ_COUNT = new GlobalConfig(CATEGORY, "dnsmasq.restartAfterNumberOfSIGUSER1");
    @GlobalConfigValidation
    public static GlobalConfig PING_INTERVAL = new GlobalConfig(CATEGORY, "ping.interval");
    @GlobalConfigValidation
    public static GlobalConfig PING_PARALLELISM_DEGREE = new GlobalConfig(CATEGORY, "ping.parallelismDegree");
    @GlobalConfigValidation
    public static GlobalConfig SSH_USERNAME = new GlobalConfig(CATEGORY, "ssh.username");
    @GlobalConfigValidation
    public static GlobalConfig SSH_PORT = new GlobalConfig(CATEGORY, "ssh.port");
    @GlobalConfigValidation
    public static GlobalConfig VYOS_PASSWORD = new GlobalConfig(CATEGORY, "vrouter.password");
    @GlobalConfigValidation
    public static GlobalConfig VYOS_ECHO_TIMEOUT = new GlobalConfig(CATEGORY, "vrouter.echoTimeout");
}
