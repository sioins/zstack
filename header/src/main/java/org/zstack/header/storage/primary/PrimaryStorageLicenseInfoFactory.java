package org.zstack.header.storage.primary;

import org.zstack.header.core.ReturnValueCompletion;

public interface PrimaryStorageLicenseInfoFactory {
    void getPrimaryStorageLicenseInfo(String primaryStorageUuid, final ReturnValueCompletion<PrimaryStorageLicenseInfo> completion);

    PrimaryStorageVendor getPrimaryStorageVendor();
}
